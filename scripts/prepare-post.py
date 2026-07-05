#!/usr/bin/env python3
import re
import shutil
import subprocess
import sys
import unicodedata
from datetime import datetime
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
POSTS = ROOT / "content" / "posts"
STATIC_IMAGES = ROOT / "static" / "images"


def slugify(value: str, fallback: str) -> str:
    value = unicodedata.normalize("NFKD", value).strip().lower()
    value = re.sub(r"[^\w\u4e00-\u9fff-]+", "-", value)
    value = re.sub(r"-+", "-", value).strip("-")
    return value or fallback


def has_frontmatter(text: str) -> bool:
    return text.startswith("---\n")


def first_title(lines: list[str], fallback: str) -> str:
    for line in lines:
        stripped = line.strip()
        if stripped:
            return stripped.lstrip("#").strip() or fallback
    return fallback


def ensure_frontmatter(text: str, title: str) -> str:
    if has_frontmatter(text):
        return ensure_typora_root(text)

    lines = text.splitlines()
    for index, line in enumerate(lines):
        if line.strip():
            if not line.lstrip().startswith("#"):
                lines[index] = f"# {line.strip()}"
            break

    now = datetime.now().astimezone().strftime("%Y-%m-%dT%H:%M:%S%z")
    frontmatter = "\n".join([
        "---",
        f'title: "{title}"',
        f"date: {now}",
        'description: ""',
        "draft: false",
        "typora-root-url: ../../static",
        "---",
        "",
    ])
    return frontmatter + "\n".join(lines).lstrip() + "\n"


def ensure_typora_root(text: str) -> str:
    end = text.find("\n---", 4)
    if end == -1:
        return text

    frontmatter = text[:end]
    rest = text[end:]
    if re.search(r"^typora-root-url:", frontmatter, re.MULTILINE):
        return text

    return frontmatter + "\ntypora-root-url: ../../static" + rest


def convert_to_jpg(source: Path, target: Path) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    result = subprocess.run(
        ["sips", "-s", "format", "jpeg", str(source), "--out", str(target)],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    if result.returncode != 0:
        shutil.copy2(source, target)


def prepare_images(text: str, post_file: Path, slug: str) -> str:
    image_dir = STATIC_IMAGES / slug
    counter = 0

    def replace(match: re.Match[str]) -> str:
        nonlocal counter
        alt = match.group(1)
        raw_path = match.group(2).strip()

        if raw_path.startswith(("http://", "https://", "/images/")):
            return match.group(0)

        source = Path(raw_path)
        if not source.is_absolute():
            source = (post_file.parent / source).resolve()

        if not source.exists():
            return match.group(0)

        counter += 1
        target = image_dir / f"{counter}.jpg"
        convert_to_jpg(source, target)
        return f"![{alt}](/images/{slug}/{counter}.jpg)"

    return re.sub(r"!\[([^\]]*)\]\(([^)]+)\)", replace, text)


def main() -> int:
    if len(sys.argv) != 2:
        print("用法: scripts/prepare-post.py content/posts/文章.md")
        return 1

    post_file = (ROOT / sys.argv[1]).resolve()
    if not post_file.exists():
        print(f"找不到文章: {post_file}")
        return 1
    if POSTS not in post_file.parents:
        print("文章需要放在 content/posts/ 里面。")
        return 1

    text = post_file.read_text(encoding="utf-8")
    title = first_title(text.splitlines(), post_file.stem)
    slug = slugify(title, post_file.stem)

    text = ensure_frontmatter(text, title)
    text = prepare_images(text, post_file, slug)
    post_file.write_text(text, encoding="utf-8")

    print(f"已整理文章: {post_file.relative_to(ROOT)}")
    print(f"图片目录: static/images/{slug}/")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
