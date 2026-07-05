---
title: "我的博客发布流程"
date: 2026-07-05T19:58:00+0800
description: "记录从写 Markdown、整理图片、补 Hugo 抬头，到双击发布并自动部署到 Cloudflare Pages 的完整流程。"
draft: false
typora-root-url: ../../static
---

现在我的博客已经形成了一套比较顺手的发布流程。

我只需要负责写文章，剩下的整理、构建、提交、推送和部署，都交给自动化脚本完成。

## 写文章

文章统一放在：

```text
/Users/xuehua/Documents/blog/content/posts/
```

每一篇文章都是一个 Markdown 文件，例如：

```text
你好.md
```

文件名很重要。图片目录会按照 Markdown 文件名来生成，而不是按照文章第一行标题。

比如 `你好.md` 里的图片会放到：

```text
/Users/xuehua/Documents/blog/static/images/你好/
```

图片会自动编号成：

```text
1.jpg
2.jpg
3.jpg
```

## 整理文章

写文章时，我不需要手动写 Hugo 抬头。

发布脚本会自动补齐：

```yaml
---
title: "文章标题"
date: 2026-07-05T19:58:00+0800
description: ""
draft: false
typora-root-url: ../../static
---
```

其中 `typora-root-url` 是为了让我在本地 Typora 里也能看到图片。

## 整理图片

图片有两种来源。

一种是本地图片，比如 Typora 自动保存到本机临时目录里的图片。

另一种是网上复制来的图片。

无论是哪一种，发布脚本都会把图片保存到博客自己的 `static/images/文章文件名/` 目录里。

这样做的好处是：

- 本地预览能显示
- 线上博客能显示
- 不依赖外部图片链接
- 原网站图片失效后，我的博客图片也不会跟着失效

文章里最终使用这样的图片路径：

```markdown
![图片说明](/images/你好/1.jpg)
```

## 双击发布

写完文章后，我只需要双击：

```text
/Users/xuehua/Documents/blog/发布博客.command
```

双击后会打开终端窗口，并实时显示 5 个步骤：

```text
第 1/5 步：检查新增、修改、删除的文件
第 2/5 步：只整理新增或修改过的文章
第 3/5 步：运行 Hugo 构建检查
第 4/5 步：准备本次变更并提交
第 5/5 步：推送到 GitHub，等待 Cloudflare 自动部署
```

如果发布成功，会弹出成功提示。

如果发布失败，会弹出失败原因，并打开日志文件。

## 不全量处理

发布脚本不会每次重新整理所有文章。

它会通过 Git 检查哪些文件发生了变化，然后只整理新增或修改过的 Markdown 文章。

如果以后有很多文章，比如一千篇，它也不会把所有文章都重新处理一遍。

删除文章时，Git 会识别删除动作，发布脚本会把删除同步到 GitHub。

## 自动部署

本地发布脚本会把更新推送到 GitHub：

```text
https://github.com/itpeiqi/Blog
```

Cloudflare Pages 会监听 GitHub 仓库。

只要 GitHub 有新的提交，Cloudflare Pages 就会自动构建并部署。

博客地址是：

```text
https://blog-auj.pages.dev
```

这样，我的日常写作流程就变成了：

```text
写文章 -> 双击发布 -> 等成功提示 -> 打开博客查看
```

这就是现在的完整博客发布系统。
