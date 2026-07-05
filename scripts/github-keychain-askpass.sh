#!/bin/sh

case "$1" in
  *Username*)
    printf '%s' 'itpeiqi'
    ;;
  *Password*)
    security find-internet-password -a 'itpeiqi' -s 'github.com' -w 2>/dev/null
    ;;
  *)
    security find-internet-password -a 'itpeiqi' -s 'github.com' -w 2>/dev/null
    ;;
esac
