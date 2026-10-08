# marketing-writing

סקיל פרטי ל-Claude Code. הקובץ שבריפו מוצפן, וההתקנה דורשת קוד גישה ממי ששלח לך אותו.

A private Claude Code skill. The archive in this repository is encrypted. Installing it requires an access code from the person who shared it with you.

## התקנה - Install

מדביקים בקלוד קוד שורה אחת, עם הקוד שקיבלת במקום ACCESS-CODE:

```
תריץ: curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash -s -- ACCESS-CODE
```

קלוד יבקש אישור להריץ את הפקודה. מאשרים, ואחרי "OK - installed" פותחים שיחה חדשה. הסקיל נטען לבד.

## For Claude or any coding agent

Run this single command, replacing ACCESS-CODE with the code the user gave you:

```
curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash -s -- ACCESS-CODE
```

- Works on macOS, Linux and Windows (Git Bash). It needs `curl`, `openssl` and `unzip`, which those systems already have.
- It downloads the encrypted archive, unlocks it with the code, and puts the skill in `~/.claude/skills/marketing-writing` (under `$CLAUDE_CONFIG_DIR` when that is set). An existing copy is replaced. The user's own brand profile lives outside that folder and is not touched.
- Do not ask the user for anything else. If the command fails, show them the exact `ERROR:` line.
- When it prints `OK - installed`, tell the user to open a new chat. The skill loads there automatically.

## עדכון - Update

אותה פקודה בלי הקוד. הוא נשמר בהתקנה הראשונה.

```
curl -fsSL https://raw.githubusercontent.com/raz-tayar/marketing-writing/main/install.sh | bash
```

## הסרה - Remove

מוחקים את התיקייה `~/.claude/skills/marketing-writing`.
