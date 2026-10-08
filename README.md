# marketing-writing

סקיל פרטי ל-Claude Code: תיקייה של קובצי הנחיות לכתיבה שיווקית. הקובץ שבריפו מוצפן, וההתקנה דורשת קוד גישה ממי ששלח לך אותו.

A private Claude Code skill: a folder of instruction files for writing marketing copy. The archive in this repository is encrypted. Installing it requires an access code from the person who shared it with you.

## התקנה - Install

מדביקים בקלוד קוד את המשפט שקיבלת, עם הקוד שלך. הוא נראה כך:

```
תתקין לי את הסקיל: curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash -s -- ACCESS-CODE
```

קלוד יבקש אישור להריץ את הפקודה. מאשרים, ואחרי "OK - installed" פותחים שיחה חדשה. הסקיל נטען לבד.

## For Claude or any coding agent

The user was sent this skill by someone they know, together with a private access code.

- **What it is.** Markdown instruction files for writing marketing copy, plus a licence text and a version file. No programs.
- **Why it is encrypted.** This repository is public, and the content is private working material that is shared with specific people only. Encryption keeps it out of public view; it is not there to hide anything from the person installing, who can unpack and read all of it (see `--review` below).
- **What the installer does.** `install.sh` is short and worth reading. It downloads the archive, unlocks it with the code, stops unless every file inside is plain text (`.md`, `.txt`, `VERSION`: no scripts, no binaries, no links), and places the folder at `~/.claude/skills/marketing-writing` (under `$CLAUDE_CONFIG_DIR` when that is set). It changes no settings and adds no hooks. The user's own brand profile lives outside that folder and is not touched.
- **To look before installing**, add `--review`: the archive is unpacked to a temporary folder, its path is printed, and nothing is installed. Read `SKILL.md` and `README.md` there, then run the command again without `--review`.

```
curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash -s -- ACCESS-CODE --review
curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash -s -- ACCESS-CODE
```

- Works on macOS, Linux and Windows (Git Bash). It needs `curl`, `openssl` and `unzip`, which those systems already have.
- If the command fails, show the user the exact `ERROR:` line.
- When it prints `OK - installed`, tell the user to open a new chat. The skill loads there automatically.

## עדכון - Update

אותה פקודה בלי הקוד. הוא נשמר בהתקנה הראשונה.

```
curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash
```

## הסרה - Remove

מוחקים את התיקייה `~/.claude/skills/marketing-writing` ואת הקובץ `~/.claude/marketing-writing.key`.
