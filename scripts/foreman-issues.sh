#!/usr/bin/env zsh
# foreman issues — Lightweight issue tracking for standalone mode.
# Works without Paperclip. Stores issues in ~/.foreman/issues.json.
#
# Usage:
#   foreman issues                    # list open issues
#   foreman issues add "Fix the bug"   # create an issue
#   foreman issues close 1            # close an issue
#   foreman issues show 1             # show issue details
#   foreman issues assign 1 builder   # assign to a role

set -euo pipefail

CONFIG_DIR="${FOREMAN_CONFIG_DIR:-$HOME/.foreman}"
ISSUES_FILE="$CONFIG_DIR/issues.json"

G='\033[0;32m' R='\033[0;31m' Y='\033[1;33m' B='\033[0;34m' BOLD='\033[1m' DIM='\033[2m' NC='\033[0m'

ACTION="${1:-list}"
shift || true

mkdir -p "$CONFIG_DIR"

# Initialize issues file if missing
if [[ ! -f "$ISSUES_FILE" ]]; then
  echo '{"next_id":1,"issues":[]}' > "$ISSUES_FILE"
fi

case "$ACTION" in
  list)
    ISSUES=$(cat "$ISSUES_FILE")
    OPEN=$(echo "$ISSUES" | python3 -c "
import json, sys
data = json.load(sys.stdin)
open_issues = [i for i in data['issues'] if i['status'] == 'open']
if not open_issues:
    print('  No open issues.')
else:
    for i in open_issues:
        assignee = f'  → {i.get(\"assignee\",\"unassigned\")}' if i.get('assignee') else ''
        print(f'  #{i[\"id\"]}  {i[\"title\"]}  [{i.get(\"priority\",\"normal\")}]{assignee}')
" 2>/dev/null)
    echo -e "${B}Open Issues${NC}"
    echo "$OPEN"
    echo ""
    ;;

  add)
    TITLE="${1:-}"
    if [[ -z "$TITLE" ]]; then
      echo -e "${R}Usage: foreman issues add \"Issue title\"${NC}"; exit 1
    fi
    python3 -c "
import json, sys
with open('$ISSUES_FILE') as f:
    data = json.load(f)
issue = {
    'id': data['next_id'],
    'title': '''$TITLE''',
    'status': 'open',
    'priority': 'normal',
    'assignee': None,
    'created': '$(date -u +%Y-%m-%dT%H:%M:%SZ)',
    'dispatched': False,
    'attempts': 0
}
data['issues'].append(issue)
data['next_id'] += 1
with open('$ISSUES_FILE', 'w') as f:
    json.dump(data, f, indent=2)
print(f'  Created issue #{issue[\"id\"]}: {issue[\"title\"]}')
"
    ;;

  close)
    ID="${1:-}"
    if [[ -z "$ID" ]]; then
      echo -e "${R}Usage: foreman issues close <id>${NC}"; exit 1
    fi
    python3 -c "
import json, sys
with open('$ISSUES_FILE') as f:
    data = json.load(f)
for i in data['issues']:
    if i['id'] == $ID:
        i['status'] = 'closed'
        i['closed'] = '$(date -u +%Y-%m-%dT%H:%M:%SZ)'
        print(f'  ✓ Closed issue #$ID')
        break
else:
    print(f'  ✗ Issue #$ID not found')
with open('$ISSUES_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
    ;;

  show)
    ID="${1:-}"
    if [[ -z "$ID" ]]; then
      echo -e "${R}Usage: foreman issues show <id>${NC}"; exit 1
    fi
    python3 -c "
import json, sys
with open('$ISSUES_FILE') as f:
    data = json.load(f)
for i in data['issues']:
    if i['id'] == $ID:
        for k, v in i.items():
            print(f'  {k}: {v}')
        break
else:
    print(f'  ✗ Issue #$ID not found')
"
    ;;

  assign)
    ID="${1:-}"
    ASSIGNEE="${2:-}"
    if [[ -z "$ID" ]] || [[ -z "$ASSIGNEE" ]]; then
      echo -e "${R}Usage: foreman issues assign <id> <role>${NC}"; exit 1
    fi
    python3 -c "
import json
with open('$ISSUES_FILE') as f:
    data = json.load(f)
for i in data['issues']:
    if i['id'] == $ID:
        i['assignee'] = '$ASSIGNEE'
        print(f'  ✓ Assigned issue #$ID to $ASSIGNEE')
        break
else:
    print(f'  ✗ Issue #$ID not found')
with open('$ISSUES_FILE', 'w') as f:
    json.dump(data, f, indent=2)
"
    ;;

  *)
    echo -e "${B}Foreman Issues${NC} ${DIM}(standalone mode)${NC}"
    echo ""
    echo -e "  ${DIM}foreman issues${NC}                    list open issues"
    echo -e "  ${DIM}foreman issues add \"Fix bug\"${NC}      create issue"
    echo -e "  ${DIM}foreman issues close 1${NC}            close issue"
    echo -e "  ${DIM}foreman issues show 1${NC}             show details"
    echo -e "  ${DIM}foreman issues assign 1 builder${NC}  assign to role"
    ;;
esac