#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

LOG_FILE="$(mktemp -t blog-publish.XXXXXX.log)"

show_success() {
  local message="$1"
  if [[ "${BLOG_PUBLISH_NO_DIALOG:-}" == "1" ]]; then
    echo "$message"
  else
    osascript -e "display dialog \"$message\" buttons {\"好的\"} default button \"好的\" with title \"博客发布\""
  fi
}

show_failure() {
  local message="$1"
  if [[ "${BLOG_PUBLISH_NO_DIALOG:-}" == "1" ]]; then
    echo "$message"
  else
    osascript -e "display dialog \"$message\" buttons {\"打开日志\", \"好的\"} default button \"好的\" with title \"博客发布失败\"" || true
    open -a TextEdit "$LOG_FILE" || true
  fi
}

step() {
  echo
  echo "第 $1/5 步：$2"
  echo "----------------------------------------"
}

changed_markdown_posts() {
  git -c core.quotePath=false status --porcelain -- content/posts | while IFS= read -r line; do
    status="${line:0:2}"
    path="${line:3}"

    case "$status" in
      *D*) continue ;;
    esac

    if [[ "$path" == content/posts/*.md && -f "$path" ]]; then
      echo "$path"
    fi
  done | sort -u
}

run_publish() {
  step 1 "检查新增、修改、删除的文件"
  git -c core.quotePath=false status --short

  posts=()
  while IFS= read -r post; do
    posts+=("$post")
  done < <(changed_markdown_posts)
  if [[ "${#posts[@]}" -eq 0 ]]; then
    echo "没有新增或修改的文章需要整理。"
  else
    echo "需要整理的文章："
    printf ' - %s\n' "${posts[@]}"
  fi

  step 2 "只整理新增或修改过的文章"
  if [[ "${#posts[@]}" -eq 0 ]]; then
    echo "跳过：没有文章需要整理。"
  else
    while IFS= read -r post; do
      ./scripts/prepare-post.py "$post"
    done < <(printf '%s\n' "${posts[@]}")
  fi

  step 3 "运行 Hugo 构建检查"
  hugo

  step 4 "准备本次变更并提交"
  git add -u
  git -c core.quotePath=false status --porcelain -- .gitignore README.md archetypes assets content drafts hugo.toml layouts scripts static themes 发布博客.command | while IFS= read -r line; do
    path="${line:3}"
    if [[ -e "$path" ]]; then
      git add "$path"
    fi
  done

  if git diff --cached --quiet; then
    echo "没有发现需要发布的新内容。"
    if git rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then
      ahead_count="$(git rev-list --count "@{u}..HEAD")"
      if [[ "$ahead_count" -gt 0 ]]; then
        echo "发现本地已有 $ahead_count 个提交尚未推送。"
        step 5 "推送到 GitHub，等待 Cloudflare 自动部署"
        git push
        return 0
      fi
    fi
    return 2
  fi

  echo "本次将提交："
  git -c core.quotePath=false diff --cached --stat
  git commit -m "Publish blog update $(date '+%Y-%m-%d %H:%M')"

  step 5 "推送到 GitHub，等待 Cloudflare 自动部署"
  git push
}

echo "博客发布开始。"
echo "日志文件：$LOG_FILE"
echo

if run_publish 2>&1 | tee "$LOG_FILE"; then
  show_success $'发布成功！Cloudflare Pages 会自动部署。\n\n网站地址：\nhttps://blog-auj.pages.dev'
  exit 0
else
  code=${PIPESTATUS[0]}
  if [[ "$code" == "2" ]]; then
    show_success $'没有新内容需要发布。\n\n你可以继续写文章，写完后再双击发布。'
    exit 0
  fi

  reason="$(tail -n 12 "$LOG_FILE" | sed 's/"/\\"/g')"
  show_failure "发布失败。\n\n原因：\n$reason\n\n完整日志已保存到：\n$LOG_FILE"
  cat "$LOG_FILE"
  exit "$code"
fi
