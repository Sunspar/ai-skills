#!/bin/sh
# Rebuild <vault>/index.md from the notes on disk, grouped by top-level folder.
# Leaves out index.md, AGENTS.md, README.md, and the skill-feedback/ queue.
# Usage: reindex.sh <vault-dir>
set -eu

vault="${1:?Usage: reindex.sh <vault-dir>}"
vault="${vault%/}"
[ -d "$vault" ] || { echo "reindex: no such directory: $vault" >&2; exit 1; }

notes=$(cd "$vault" && find . -type f -name '*.md' \
  ! -path './.git/*' ! -path './skill-feedback/*' \
  ! -path './index.md' ! -path './AGENTS.md' ! -path './README.md' \
  | sed 's|^\./||; s|\.md$||' | LC_ALL=C sort)

capitalize() {
  printf '%s' "$1" | awk '{ print toupper(substr($0, 1, 1)) substr($0, 2) }'
}

{
  echo "# Brain"
  for section in $(printf '%s\n' "$notes" | grep '/' | cut -d/ -f1 | LC_ALL=C sort -u); do
    printf '\n## %s\n' "$(capitalize "$section")"
    printf '%s\n' "$notes" | grep "^$section/" | sed 's/.*/- [[&]]/'
  done
  standalone=$(printf '%s\n' "$notes" | grep -v '/' || true)
  if [ -n "$standalone" ]; then
    printf '\n## Other\n'
    printf '%s\n' "$standalone" | sed 's/.*/- [[&]]/'
  fi
} > "$vault/index.md"

echo "$vault/index.md"
