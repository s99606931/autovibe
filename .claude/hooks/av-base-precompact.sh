#!/bin/bash
# name: av-base-precompact
# autovibe: true
# version: 1.0
# created: 2026-03-29
# hook-type: SessionStart
# matcher: compact
# description: 컨텍스트 압축 전 메모리 상태 보존

set -euo pipefail
CLAUDE_PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_FILE="${CLAUDE_PROJECT_DIR}/.claude/logs/compact.log"
mkdir -p "$(dirname "$LOG_FILE")"

TIMESTAMP=$(date +"%Y-%m-%dT%H:%M:%S")
echo "${TIMESTAMP} | COMPACT | context compression triggered" >> "$LOG_FILE"

exit 0
