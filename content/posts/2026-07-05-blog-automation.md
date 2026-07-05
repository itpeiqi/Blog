---
title: "博客自动化系统搭建记录"
date: 2026-07-05T19:05:00+0800
description: "记录这次把 Hugo 博客接入 GitHub 和 Cloudflare Pages，并整理出自动发文流程。"
draft: false
typora-root-url: ../../static
---

# 博客自动化系统搭建记录

今天完成了一个 Hugo 格式的个人博客，并部署到了 Cloudflare Pages。

博客源码放在本机：

```text
/Users/xuehua/Documents/blog
```

GitHub 仓库是：

```text
https://github.com/itpeiqi/Blog
```

线上地址是：

```text
https://blog-auj.pages.dev
```

## 自动化规则

以后每次问题解决后，都把结果整理成一篇 Hugo 格式的 Markdown 文章，放到：

```text
content/posts/
```

文章需要包含标题、发布时间、简介和正文。

## 发布流程

本地修改完成后，运行发布脚本：

```bash
./scripts/publish.sh
```

脚本会自动完成：

- Hugo 构建检查
- Git 提交
- 推送到 GitHub
- 触发 Cloudflare Pages 自动部署

这样以后只需要专心写内容，剩下的发布流程交给自动化处理。
