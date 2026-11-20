#!/bin/sh
# Link this repo's skills into every Claude and Codex home on the machine.
#
#   Codex:  ~/.agents/skills/<folder> -> <repo>/skills/<folder>, one link per top-level
#           folder. Codex reads ~/.agents/skills whatever CODEX_HOME is, and finds nested
#           skills. Links into this repo inside ~/.codex*/skills are removed as duplicates.
#   Claude: <home>/skills/<skill> -> <repo>/skills/<folder>/<skill>, one link per skill, in
#           every ~/.claude*/ home with a skills/ folder. Claude only reads one level deep.
#           When two folders hold a skill of the same name, engineering-kitchen wins.
#
# Links always point at the main checkout, so they survive worktree cleanup. Links into
# this repo that no longer match a skill are removed; nothing else is touched.
#
# Refresh: git -C <main checkout> pull --ff-only && <main checkout>/scripts/sync-skill-links.sh
set -eu

script_dir=$(cd "$(dirname "$0")" && pwd -P)
repo=$(dirname "$(git -C "$script_dir" rev-parse --path-format=absolute --git-common-dir)")
skills="$repo/skills"

wanted=$(mktemp)
trap 'rm -f "$wanted"' EXIT

# link <path> <target>
link() {
  if [ -L "$1" ] && [ "$(readlink "$1")" = "$2" ]; then return; fi
  if [ -e "$1" ] && [ ! -L "$1" ]; then
    echo "skip $1: exists and is not a link" >&2
    return
  fi
  ln -sfn "$2" "$1"
  echo "linked $1 -> $2"
}

# prune <dir>: remove links into this repo that are not listed in $wanted as "<name>\t<target>"
prune() {
  for entry in "$1"/* "$1"/.[!.]*; do
    [ -L "$entry" ] || continue
    target=$(readlink "$entry")
    case "$target" in
      "$skills" | "$skills"/*) ;;
      *) continue ;;
    esac
    if ! grep -qxF "$(basename "$entry")	$target" "$wanted"; then
      rm "$entry"
      echo "removed $entry -> $target"
    fi
  done
}

# Codex: one link per top-level folder in ~/.agents/skills.
agents="$HOME/.agents/skills"
if [ -L "$agents" ]; then
  rm "$agents"
  echo "removed whole-tree link $agents"
fi
mkdir -p "$agents"
: > "$wanted"
for folder in "$skills"/*/; do
  name=$(basename "$folder")
  printf '%s\t%s\n' "$name" "$skills/$name" >> "$wanted"
  link "$agents/$name" "$skills/$name"
done
prune "$agents"

: > "$wanted"
for home in "$HOME"/.codex*/; do
  [ -d "${home}skills" ] && prune "${home}skills"
done

# Claude: one link per skill in each home; engineering-kitchen first so it wins a name clash.
find "$skills" -mindepth 3 -maxdepth 3 -name SKILL.md | while IFS= read -r file; do
  dir=$(dirname "$file")
  priority=1
  [ "$(basename "$(dirname "$dir")")" = engineering-kitchen ] && priority=0
  printf '%s\t%s\t%s\n' "$priority" "$(basename "$dir")" "$dir"
done | LC_ALL=C sort | awk -F '\t' '
  $2 in kept { print "name clash: " $3 " hidden by " kept[$2] > "/dev/stderr"; next }
  { kept[$2] = $3; print $2 "\t" $3 }
' > "$wanted"

for home in "$HOME"/.claude*/; do
  [ -d "${home}skills" ] || continue
  while IFS="	" read -r name target; do
    link "${home}skills/$name" "$target"
  done < "$wanted"
  prune "${home}skills"
done
