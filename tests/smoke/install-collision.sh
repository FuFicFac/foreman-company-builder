#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
SOURCE="$WORK/source"
INSTALL="$WORK/home/.foreman"
mkdir -p "$SOURCE/scripts" "$WORK/home"
printf '#!/usr/bin/env bash\necho fixture\n' > "$SOURCE/scripts/foreman"
chmod +x "$SOURCE/scripts/foreman"
git -C "$SOURCE" init -q
git -C "$SOURCE" add .
git -C "$SOURCE" -c user.name='Foreman Test' -c user.email='foreman-test@example.invalid' commit -qm 'fixture'
git -C "$SOURCE" branch -M main

mkdir -p "$INSTALL"
printf '{"version":"old"}\n' > "$INSTALL/profile.json"
printf 'keep this state\n' > "$INSTALL/runs.json"
touch "$WORK/home/.zshrc"

OUTPUT="$(HOME="$WORK/home" FOREMAN_INSTALL_DIR="$INSTALL" FOREMAN_REPO_URL="$SOURCE" zsh "$ROOT/scripts/install.sh" 2>&1)"

test -d "$INSTALL/.git"
grep -qF '{"version":"old"}' "$INSTALL/profile.json"
grep -qF 'keep this state' "$INSTALL/runs.json"
BACKUP=$(find "$WORK/home" -maxdepth 1 -type d -name '.foreman.backup-*' -print -quit)
test -n "$BACKUP"
test -f "$BACKUP/profile.json"
grep -qF 'Existing runtime state preserved' <<<"$OUTPUT"
echo "install collision smoke passed"
