#!/bin/bash
# Simple functional audit for DiagMax
set -e
LOG_DIR=/tmp/diagmax/log
mkdir -p "$LOG_DIR"
RESULT="{\n  \"timestamp\": \"$(date '+%Y-%m-%d %H:%M:%S')\""

python3 client/ui/diagmax.py --help >/dev/null 2>&1 && TUI=ok || TUI=fail
RESULT+="\n  ,\"tui\": \"$TUI\""

if python3 client/ui/diagmax.py --auto >/dev/null 2>&1; then
    AUTO=ok
else
    AUTO=fail
fi
RESULT+="\n  ,\"auto\": \"$AUTO\""

if python3 client/agent.py --agent >/dev/null 2>&1; then
    NET=ok
else
    NET=fail
fi
RESULT+="\n  ,\"network\": \"$NET\""


if [ -f /tmp/diagmax/log/ai_summary/summary.md ]; then
    AI=ok
else
    AI=fail
fi
RESULT+="\n  ,\"ai_report\": \"$AI\""

lsblk -o LABEL | grep -q DIAGMAX_LOG && USB=ok || USB=fail
RESULT+="\n  ,\"usb\": \"$USB\""

[ -f diagmax.iso ] && BUILD=ok || BUILD=fail
RESULT+="\n  ,\"build\": \"$BUILD\"\n}"

echo -e "$RESULT" > "$LOG_DIR/audit.json"
