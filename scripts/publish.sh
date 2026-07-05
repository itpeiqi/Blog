#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

hugo

git add .gitignore README.md archetypes assets content drafts hugo.toml layouts scripts static themes 发布博客.command

if git diff --cached --quiet; then
  echo "没有需要发布的新内容。"
  exit 0
fi

message="${*:-Publish blog update $(date +"%Y-%m-%d %H:%M")}"
git commit -m "$message"
git push

echo "已推送到 GitHub。Cloudflare Pages 会自动部署。"
