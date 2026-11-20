#!/bin/sh
# Concatenate every .md file under a directory into one snapshot file,
# each delimited by a "=== path ===" header, so a subagent reads one file.
# Usage: snapshot.sh <dir> <output-file>
set -eu

dir="${1:?Usage: snapshot.sh <dir> <output-file>}"
output="${2:?Usage: snapshot.sh <dir> <output-file>}"

: > "$output"

find "$dir" -type f -name '*.md' -not -path '*/.git/*' -not -path '*/node_modules/*' | LC_ALL=C sort | while IFS= read -r f; do
  printf '=== %s ===\n' "$f" >> "$output"
  cat "$f" >> "$output"
  printf '\n\n' >> "$output"
done

echo "$output"
