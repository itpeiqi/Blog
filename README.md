# 我的博客

这是一个 Hugo 格式的个人博客，可以部署到 Cloudflare Pages。

## 写一篇新文章

在 `content/posts/` 里新增一个 `.md` 文件，例如 `content/posts/my-first-note.md`：

```markdown
---
title: 我的第一篇笔记
date: 2026-07-05
description: 这里写一句简介
draft: false
---

正文从这里开始。
```

## 本地预览

如果你电脑上安装了 Hugo：

```bash
hugo server
```

然后打开 Hugo 显示的网址。

## Cloudflare Pages 设置

- Framework preset：Hugo
- Build command：`hugo`
- Build output directory：`public`

## 自动发文

新建一篇文章：

```bash
./scripts/new-post.sh "文章标题"
```

发布到 GitHub，并触发 Cloudflare Pages 自动部署：

```bash
./scripts/publish.sh
```

也可以直接双击：

```text
发布博客.command
```

双击后会自动整理文章、构建、提交、推送。成功会弹出成功提示，失败会弹出失败原因。

## 整理已写好的文章

如果文章是自己新建的，没有 Hugo 抬头，或者里面插了 Typora 本地图片，运行：

```bash
./scripts/prepare-post.py content/posts/文章文件名.md
```

它会自动补齐 Hugo 抬头，并把图片整理到 `static/images/文章名/` 里面，按 `1.jpg`、`2.jpg` 编号。
