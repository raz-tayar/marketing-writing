#!/usr/bin/env bash
# marketing-writing - installer and updater for the Claude Code skill.
#
# First install:
#   curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash -s -- ACCESS-CODE
# Update (the code is remembered after the first install):
#   curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash
#
# What it does: downloads the encrypted archive from this repository, unlocks it with
# the access code, and puts the skill in ~/.claude/skills/marketing-writing.
# An existing copy is replaced. Nothing else on the machine is touched.
set -euo pipefail

SOURCE="${MW_SOURCE:-https://raw.githubusercontent.com/raz-tayar/marketing-writing/main}"
ROOT="${MW_INSTALL_ROOT:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}}"
NAME="marketing-writing"
SKILLS="$ROOT/skills"
KEYFILE="$ROOT/$NAME.key"
CODE="${1:-}"

say() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

for tool in curl openssl unzip; do
  command -v "$tool" >/dev/null 2>&1 || die "missing tool: $tool"
done

if [ -z "$CODE" ] && [ -f "$KEYFILE" ]; then
  CODE="$(cat "$KEYFILE")"
fi
[ -n "$CODE" ] || die "an access code is required - ask the person who sent you this skill"

TMP="$(mktemp -d 2>/dev/null || mktemp -d -t mwpack)"
trap 'rm -rf "$TMP"' EXIT

say "Downloading..."
curl -fsSL "$SOURCE/$NAME.enc" -o "$TMP/pack.enc" || die "download failed - check the internet connection and try again"

say "Unlocking..."
if ! MW_CODE="$CODE" openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 -md sha256 \
      -in "$TMP/pack.enc" -out "$TMP/pack.zip" -pass env:MW_CODE 2>/dev/null; then
  die "the access code is wrong"
fi
if ! unzip -tq "$TMP/pack.zip" >/dev/null 2>&1; then
  die "the access code is wrong (or the download is damaged - try again in a few minutes)"
fi

mkdir -p "$TMP/new"
unzip -q "$TMP/pack.zip" -d "$TMP/new"
[ -f "$TMP/new/$NAME/SKILL.md" ] || die "unexpected package layout"

mkdir -p "$SKILLS"
if [ -e "$SKILLS/$NAME" ]; then
  mv "$SKILLS/$NAME" "$TMP/old"
fi
if ! mv "$TMP/new/$NAME" "$SKILLS/$NAME"; then
  if [ -e "$TMP/old" ]; then mv "$TMP/old" "$SKILLS/$NAME"; fi
  die "could not write to $SKILLS"
fi

( umask 077; printf '%s' "$CODE" > "$KEYFILE" )

VERSION="$(cat "$SKILLS/$NAME/VERSION" 2>/dev/null || echo unknown)"
COUNT="$(find "$SKILLS/$NAME" -type f | wc -l | tr -d ' ')"
say "OK - installed $NAME, version $VERSION, $COUNT files, in $SKILLS/$NAME"
say "ההתקנה הצליחה. פותחים שיחה חדשה בקלוד קוד, והסקיל זמין."
