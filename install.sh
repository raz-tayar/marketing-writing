#!/usr/bin/env bash
# marketing-writing - installer and updater for a Claude Code skill.
#
# Install:
#   curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash -s -- ACCESS-CODE
# Look before installing (unpacks to a temporary folder, installs nothing):
#   curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash -s -- ACCESS-CODE --review
# Update (the code is remembered after the first install):
#   curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash
#
# What the skill is: a folder of Markdown instruction files for writing marketing copy. No programs.
# Why the archive is encrypted: this repository is public, and the content is private working material
# that is shared with specific people only. The access code comes from the person who shared the skill.
#
# What this script does, and all it does:
#   1. downloads marketing-writing.enc from this repository, unlocks it with the code, and checks its checksum
#   2. refuses to continue unless every file inside is plain text (.md, .txt, VERSION) - no scripts, no binaries, no links
#   3. puts the folder at ~/.claude/skills/marketing-writing, replacing an older copy of the same folder
#   4. saves the code in ~/.claude/marketing-writing.key so that an update needs no code
# It changes no settings, adds no hooks, and touches nothing else on the machine.
set -euo pipefail

SOURCE="${MW_SOURCE:-https://raw.githubusercontent.com/raz-tayar/marketing-writing/main}"
ROOT="${MW_INSTALL_ROOT:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}}"
NAME="marketing-writing"
SKILLS="$ROOT/skills"
KEYFILE="$ROOT/$NAME.key"
BACKUP="$ROOT/.$NAME.previous"
CODE=""
MODE="install"

say() { printf '%s\n' "$*"; }
die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

for arg in "$@"; do
  case "$arg" in
    --review) MODE="review" ;;
    -*) die "unknown option: $arg" ;;
    *) CODE="$arg" ;;
  esac
done

for tool in curl openssl unzip; do
  command -v "$tool" >/dev/null 2>&1 || die "missing tool: $tool"
done

if [ -z "$CODE" ] && [ -f "$KEYFILE" ]; then
  CODE="$(cat "$KEYFILE")"
fi
[ -n "$CODE" ] || die "an access code is required - ask the person who sent you this skill"

TMP="$(mktemp -d "${TMPDIR:-/tmp}/mwpack.XXXXXX")" || die "could not create a temporary folder"
trap 'rm -rf "$TMP"' EXIT

say "Downloading..."
curl -fsSL "$SOURCE/$NAME.enc" -o "$TMP/pack.enc" || die "download failed - check the internet connection and try again"
curl -fsSL "$SOURCE/$NAME.sha256" -o "$TMP/pack.sha256" || die "download failed - check the internet connection and try again"

say "Unlocking..."
# The classic key derivation with -md sha256 is understood by every openssl and LibreSSL, old and new.
# The access code is long and random, so nothing depends on a slow key derivation.
if ! MW_CODE="$CODE" openssl enc -d -aes-256-cbc -md sha256 \
      -in "$TMP/pack.enc" -out "$TMP/pack.zip" -pass env:MW_CODE 2>/dev/null; then
  die "the access code is wrong"
fi
WANT="$(tr -d ' \r\n' < "$TMP/pack.sha256")"
GOT="$(openssl dgst -sha256 "$TMP/pack.zip" | sed 's/^.*= *//' | tr -d ' \r\n')"
if [ -z "$WANT" ] || [ "$WANT" != "$GOT" ]; then
  die "the access code is wrong (or the download is damaged - try again in a few minutes)"
fi

# Look at the list of entries before anything is unpacked: one top folder, safe names, plain-text types only.
if unzip -Z1 "$TMP/pack.zip" > "$TMP/list.txt" 2>/dev/null; then
  ODD="$(grep -v -E "^$NAME/([A-Za-z0-9._-]+/)*([A-Za-z0-9._-]+\.(md|txt)|VERSION)?$" "$TMP/list.txt" | head -5 || true)"
  [ -z "$ODD" ] || die "the package holds an unexpected entry - nothing was installed: $ODD"
  if grep -q -E '(^|/)\.\.?(/|$)' "$TMP/list.txt"; then
    die "the package holds an unsafe path - nothing was installed"
  fi
  if unzip -Z "$TMP/pack.zip" 2>/dev/null | grep -q '^l'; then
    die "the package holds a link - nothing was installed"
  fi
fi

mkdir -p "$TMP/new"
unzip -q "$TMP/pack.zip" -d "$TMP/new"
[ -f "$TMP/new/$NAME/SKILL.md" ] || die "unexpected package layout"
[ "$(ls -A "$TMP/new" | wc -l | tr -d ' ')" = "1" ] || die "unexpected package layout"

# The same check again on what was actually unpacked, plus the content: a file with a NUL byte is not text.
OTHER="$(find "$TMP/new" ! -type d ! \( -type f \( -name '*.md' -o -name '*.txt' -o -name 'VERSION' \) \) | head -5 || true)"
[ -z "$OTHER" ] || die "the package holds something that is not a plain text file - nothing was installed: $OTHER"
BINARY="$(find "$TMP/new" -type f -exec sh -c '
  for f; do
    if [ "$(LC_ALL=C tr -d "\000" < "$f" | wc -c | tr -d " ")" != "$(wc -c < "$f" | tr -d " ")" ]; then printf "%s\n" "$f"; fi
  done' sh {} + | head -5 || true)"
[ -z "$BINARY" ] || die "the package holds a file that is not plain text - nothing was installed: $BINARY"
find "$TMP/new" -type d -exec chmod 755 {} +
find "$TMP/new" -type f -exec chmod 644 {} +

TOTAL="$(find "$TMP/new/$NAME" -type f | wc -l | tr -d ' ')"
MD="$(find "$TMP/new/$NAME" -type f -name '*.md' | wc -l | tr -d ' ')"
VERSION="$(cat "$TMP/new/$NAME/VERSION" 2>/dev/null || echo unknown)"

if [ "$MODE" = "review" ]; then
  OUT="$(mktemp -d "${TMPDIR:-/tmp}/mwreview.XXXXXX")" || die "could not create a temporary folder"
  mv "$TMP/new/$NAME" "$OUT/$NAME"
  say "REVIEW ONLY - nothing was installed."
  say "Unpacked to: $OUT/$NAME"
  say "Version $VERSION, $TOTAL files, $MD of them Markdown, the rest plain text. Start with SKILL.md and README.md."
  say "To install, run the same command without --review. The review folder can be deleted."
  exit 0
fi

# Swap the folder in. The previous copy is kept aside until the new one is in place.
mkdir -p "$SKILLS"
rm -rf "$BACKUP"
if [ -e "$SKILLS/$NAME" ] || [ -L "$SKILLS/$NAME" ]; then
  mv "$SKILLS/$NAME" "$BACKUP"
fi
if ! mv "$TMP/new/$NAME" "$SKILLS/$NAME"; then
  if [ -e "$BACKUP" ]; then
    mv "$BACKUP" "$SKILLS/$NAME" || die "could not write to $SKILLS - the previous copy is kept at $BACKUP"
  fi
  die "could not write to $SKILLS - nothing was changed"
fi
rm -rf "$BACKUP"

# Save the code through a temporary file and a rename, so an existing file or link is replaced, not written through.
if ( umask 077; printf '%s' "$CODE" > "$TMP/key" ) && mv -f "$TMP/key" "$KEYFILE"; then
  chmod 600 "$KEYFILE" 2>/dev/null || true
else
  say "Note: the access code could not be saved, so the next update will need it again."
fi

say "OK - installed $NAME, version $VERSION, $TOTAL plain-text files ($MD Markdown), in $SKILLS/$NAME"
say "ההתקנה הצליחה. פותחים שיחה חדשה בקלוד קוד, והסקיל זמין."
