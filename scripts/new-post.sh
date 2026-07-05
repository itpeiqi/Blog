#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

title="${*:-新文章}"
stamp="$(date +"%Y-%m-%dT%H:%M:%S%z")"
day="$(date +"%Y-%m-%d")"
slug="$(date +"%H%M%S")"
file="content/posts/${day}-${slug}.md"

cat > "$file" <<POST
---
title: "$title"
date: $stamp
description: ""
draft: false
---

# $title

这里写正文。
POST

echo "$file"
