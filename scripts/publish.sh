#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

build_dir="${TMPDIR:-/private/tmp}/blog-public-$$"
trap 'rm -rf "$build_dir"' EXIT

hugo --destination "$build_dir" --noBuildLock --noTimes --noChmod

git add .gitignore README.md archetypes content drafts hugo.toml layouts scripts static 发布博客.command

if git diff --cached --quiet; then
  echo "没有需要发布的新内容。"
  exit 0
fi

message="${*:-Publish blog update $(date +"%Y-%m-%d %H:%M")}"
git commit -m "$message"
git push

echo "已推送到 GitHub。Cloudflare Pages 会自动部署。"
