# CODEX Notes

This file is the handoff note for future Codex conversations.

Always read this file first when working on this blog.

## Project

- Blog directory: `/Users/xuehua/Documents/blog`
- Static site generator: Hugo
- GitHub repository: `https://github.com/itpeiqi/Blog`
- Cloudflare Pages project: `blog`
- Public domain: `https://blog.leesy.cc`
- Old Cloudflare Pages domain: `https://blog-auj.pages.dev`

## Important Rules

- Do not place this blog under any Codex workspace folder.
- The real blog lives at `/Users/xuehua/Documents/blog`.
- Do not write secrets, GitHub tokens, passwords, verification codes, or private credentials into files, commits, blog posts, or chat replies.
- If documenting authentication, describe the method only. Never include the actual token or code.
- When a task is finished and it is worth remembering, update this file.

## Publishing Flow

The user writes Markdown posts in:

```text
/Users/xuehua/Documents/blog/content/posts/
```

The normal publishing entry point is:

```text
/Users/xuehua/Documents/blog/发布博客.command
```

The command runs:

```text
/Users/xuehua/Documents/blog/scripts/publish-button.sh
```

The publishing script shows progress by actual action, without a fixed total:

1. Check added, modified, and deleted files.
2. Prepare only newly added or modified Markdown posts.
3. Run a Hugo build check.
4. Stage and commit changes.
5. Push to GitHub and let Cloudflare Pages deploy, only when there is something to push.

On success, the dialog should show:

```text
https://blog.leesy.cc
```

## Markdown And Images

The post preparation script is:

```text
/Users/xuehua/Documents/blog/scripts/prepare-post.py
```

Expected behavior:

- Add Hugo front matter when missing.
- Use the Markdown file name as the image directory name.
- Save local and remote images into `static/images/<article-file-name>/`.
- Rename article images as `1.jpg`, `2.jpg`, and so on.
- Rewrite image links so they work both locally and on the deployed blog.
- Avoid processing every article each time; only changed posts should be prepared.

## Dynamic Features

The blog is still a static Hugo site, but has lightweight dynamic behavior:

- Search page: `/search/`
- Search content page: `content/search.md`
- Search template: `layouts/_default/search.html`
- Search index template: `layouts/index.json`
- Search script: `static/js/search.js`

The home output in `hugo.toml` includes:

```toml
[outputs]
  home = ["HTML", "RSS", "JSON"]
```

Do not remove JSON output unless the search feature is changed.

## Theme And Style

The current design is a custom Hugo layout with a clean Apple-like style.

Important files:

```text
layouts/
static/css/styles.css
```

Do not switch themes casually. The user previously disliked Congo and Stack for this blog.

Preferred direction:

- Minimal
- Clean
- Light
- Apple-like
- Quiet, readable, not overly decorative

## GitHub Authentication

Git pushes use a long-term GitHub token stored outside the repository.

Current helper script:

```text
/Users/xuehua/Documents/blog/scripts/github-keychain-askpass.sh
```

Git config for this repository points `core.askPass` to that script.

The token itself must not be committed or printed.

If GitHub push fails:

- First check `git -C /Users/xuehua/Documents/blog status --short --branch`.
- Then test with `GIT_TERMINAL_PROMPT=0 git -C /Users/xuehua/Documents/blog ls-remote origin HEAD`.
- If credentials need repair, ask the user before changing token storage.

## Cloudflare

Cloudflare Pages deploys from GitHub automatically.

Custom domain:

```text
blog.leesy.cc
```

The Pages custom domain was added in Cloudflare and verified as accessible.

If the site is reachable at `blog.leesy.cc`, do not reconfigure DNS unless there is a clear problem.

## Recent Completed Work

- Created the Hugo blog at `/Users/xuehua/Documents/blog`.
- Connected it to GitHub repository `itpeiqi/Blog`.
- Connected Cloudflare Pages project `blog`.
- Added custom domain `blog.leesy.cc`.
- Added a one-click publish command.
- Added changed-file-only post preparation.
- Added image collection and renaming for posts.
- Added remote image downloading so posts do not depend on external image URLs.
- Added local and deployed image compatibility.
- Added a static search page with JSON index.
- Restored the custom theme and refined it toward a cleaner Apple-like style.
- Removed the incorrect author name from the footer.
- Removed duplicate article headings.
- Updated success dialogs to show `https://blog.leesy.cc`.
- Configured GitHub push authentication for smoother publishing.
- Removed fixed `/5` progress labels from the publish script.
- Updated the one-click publish command to close its Terminal window automatically after completion.

## Useful Commands

Run a Hugo build check:

```bash
hugo --destination /private/tmp/blog-public --noBuildLock --noTimes --noChmod
```

Check Git status:

```bash
git -C /Users/xuehua/Documents/blog status --short --branch
```

Push manually:

```bash
git -C /Users/xuehua/Documents/blog push
```

Run the publish script without dialogs:

```bash
BLOG_PUBLISH_NO_DIALOG=1 /Users/xuehua/Documents/blog/scripts/publish-button.sh
```
