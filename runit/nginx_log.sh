#!/bin/sh
set -e

LOG=/var/log/runit/nginx

test -d "$LOG" || mkdir -p "$LOG" && exec svlogd -tt "$LOG"