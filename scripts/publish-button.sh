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
  git status --porcelain -- content/posts | while IFS= read -r line; do
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
  git status --short

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
  while IFS= read -r post; do
    ./scripts/prepare-post.py "$post"
  done < <(printf '%s\n' "${posts[@]}")

  step 3 "运行 Hugo 构建检查"
  hugo

  step 4 "准备本次变更并提交"
  git add -u
  git status --porcelain -- .gitignore README.md archetypes content drafts hugo.toml layouts scripts static 发布博客.command | while IFS= read -r line; do
    path="${line:3}"
    if [[ -e "$path" ]]; then
      git add "$path"
    fi
  done

  if git diff --cached --quiet; then
    echo "没有发现需要发布的新内容。"
    return 2
  fi

  echo "本次将提交："
  git diff --cached --stat
  git commit -m "Publish blog update $(date '+%Y-%m-%d %H:%M')"

  step 5 "推送到 GitHub，等待 Cloudflare 自动部署"
  git push
}

if run_publish >"$LOG_FILE" 2>&1; then
  show_success $'发布成功！Cloudflare Pages 会自动部署。\n\n网站地址：\nhttps://blog-auj.pages.dev'
  cat "$LOG_FILE"
  exit 0
else
  code=$?
  if [[ "$code" == "2" ]]; then
    show_success $'没有新内容需要发布。\n\n你可以继续写文章，写完后再双击发布。'
    cat "$LOG_FILE"
    exit 0
  fi

  reason="$(tail -n 12 "$LOG_FILE" | sed 's/"/\\"/g')"
  show_failure "发布失败。\n\n原因：\n$reason\n\n完整日志已保存到：\n$LOG_FILE"
  cat "$LOG_FILE"
  exit "$code"
fi
