#!/usr/bin/env bash
cd "$(dirname "$0")"
./scripts/publish-button.sh
echo
echo "处理完成。这个窗口会自动关闭。"
(
  sleep 1
  osascript -e 'tell application "Terminal" to close front window' >/dev/null 2>&1
) &
exit 0
