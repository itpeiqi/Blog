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

run_publish() {
  echo "开始整理文章..."

  while IFS= read -r post; do
    ./scripts/prepare-post.py "$post"
  done < <(find content/posts -type f -name "*.md" | sort)

  echo "开始 Hugo 构建..."
  hugo

  echo "准备提交文件..."
  git add .gitignore README.md archetypes content drafts hugo.toml layouts scripts static 发布博客.command

  if git diff --cached --quiet; then
    echo "没有发现需要发布的新内容。"
    return 2
  fi

  echo "提交到本地 Git..."
  git commit -m "Publish blog update $(date '+%Y-%m-%d %H:%M')"

  echo "推送到 GitHub..."
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
