#!/usr/bin/env bash
cd "$(dirname "$0")"
./scripts/publish-button.sh
echo
echo "处理完成。按回车关闭这个窗口。"
read -r
