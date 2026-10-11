# marketing-writing

סקיל פרטי ל-Claude Code: תיקייה של קובצי הנחיות לכתיבה שיווקית. הקובץ שבריפו מוצפן, וההתקנה דורשת קוד גישה ממי ששלח לך אותו.

A private Claude Code skill: a folder of instruction files for writing marketing copy. The archive in this repository is encrypted. Installing it requires an access code from the person who shared it with you.

## התקנה - Install

מדביקים בקלוד קוד את המשפט שקיבלת יחד עם קוד הגישה. קלוד קורא את הדף הזה ואת סקריפט ההתקנה, מבקש אישור להריץ, ומתקין. אחרי "OK - installed" פותחים שיחה חדשה, והסקיל נטען לבד.

מי שמעדיף להתקין לבד, בלי קלוד, מדביק בטרמינל את השורה הזאת עם הקוד שלו במקום ACCESS-CODE:

```
curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash -s -- ACCESS-CODE
```

## What is in here, and how it installs

- **What it is.** Markdown instruction files for writing marketing copy, plus a licence text and a version file. No programs.
- **Why it is encrypted.** This repository is public, and the content is private working material that is shared with specific people only. Encryption keeps it out of public view. It hides nothing from the person installing, who can unpack and read all of it first (see "Looking before installing").
- **What the installer does.** [`install.sh`](install.sh) is about 140 lines and is meant to be read. It downloads `marketing-writing.enc`, unlocks it with the access code, compares its checksum with `marketing-writing.sha256`, stops unless every file inside is plain text (`.md`, `.txt`, `VERSION`: no scripts, no binaries, no links), and places the folder at `~/.claude/skills/marketing-writing` (under `$CLAUDE_CONFIG_DIR` when that is set). An older copy of that folder is replaced. It saves the access code in `~/.claude/marketing-writing.key` so that an update needs no code. It changes no settings and adds no hooks, and it does not touch the brand profile that the skill keeps outside its own folder.
- **Requirements.** macOS, Linux or Windows with Git Bash. It uses `curl`, `openssl` and `unzip`, which those systems already have.
- **Result.** The last line reads `OK - installed marketing-writing, version ...`. A failure prints one line starting with `ERROR:`. The skill becomes available in the next new chat.

### Looking before installing

With `--review` the archive is unpacked to a temporary folder, the path is printed, and nothing is installed. `SKILL.md` and `README.md` in that folder are the place to start. Running the command again without `--review` installs.

```
curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh -o install.sh
bash install.sh ACCESS-CODE --review
bash install.sh ACCESS-CODE
```

## עדכון - Update

אותה פקודה בלי הקוד. הוא נשמר בהתקנה הראשונה.

```
curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash
```

## הסרה - Remove

מוחקים את התיקייה `~/.claude/skills/marketing-writing` ואת הקובץ `~/.claude/marketing-writing.key`.
