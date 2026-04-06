#!/bin/bash
# Notification hook (idle_prompt): send macOS notification when Claude
# is waiting for input and the user hasn't responded yet.

osascript -e 'display notification "Task complete" with title "Claude Code"' 2>/dev/null
exit 0
