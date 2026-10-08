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
#   1. downloads marketing-writing.enc from this repository and unlocks it with the code
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
[ "$(ls -A "$TMP/new" | wc -l | tr -d ' ')" = "1" ] || die "unexpected package layout"

# plain text only: anything else stops the install
OTHER="$(find "$TMP/new" ! -type d ! \( -type f \( -name '*.md' -o -name '*.txt' -o -name 'VERSION' \) \) | head -5)"
[ -z "$OTHER" ] || die "the package holds something that is not a plain text file - nothing was installed: $OTHER"
find "$TMP/new" -type f -exec chmod 644 {} +

TOTAL="$(find "$TMP/new/$NAME" -type f | wc -l | tr -d ' ')"
MD="$(find "$TMP/new/$NAME" -type f -name '*.md' | wc -l | tr -d ' ')"
VERSION="$(cat "$TMP/new/$NAME/VERSION" 2>/dev/null || echo unknown)"

if [ "$MODE" = "review" ]; then
  OUT="$(mktemp -d 2>/dev/null || mktemp -d -t mwreview)"
  mv "$TMP/new/$NAME" "$OUT/$NAME"
  say "REVIEW ONLY - nothing was installed."
  say "Unpacked to: $OUT/$NAME"
  say "Version $VERSION, $TOTAL files, $MD of them Markdown, the rest plain text. Start with SKILL.md and README.md."
  say "To install, run the same command without --review. The review folder can be deleted."
  exit 0
fi

mkdir -p "$SKILLS"
if [ -e "$SKILLS/$NAME" ]; then
  mv "$SKILLS/$NAME" "$TMP/old"
fi
if ! mv "$TMP/new/$NAME" "$SKILLS/$NAME"; then
  if [ -e "$TMP/old" ]; then mv "$TMP/old" "$SKILLS/$NAME"; fi
  die "could not write to $SKILLS"
fi

( umask 077; printf '%s' "$CODE" > "$KEYFILE" )

say "OK - installed $NAME, version $VERSION, $TOTAL plain-text files ($MD Markdown), in $SKILLS/$NAME"
say "ההתקנה הצליחה. פותחים שיחה חדשה בקלוד קוד, והסקיל זמין."
