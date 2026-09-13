#!/usr/bin/env bash
set -euo pipefail
qs -c hshell ipc call hshell ping >/dev/null 2>&1 && exit 0
exec flock -n "${XDG_RUNTIME_DIR:-/run/user/$UID}/hshell-session.lock" qs -c hshell
