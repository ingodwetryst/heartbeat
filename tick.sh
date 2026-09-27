#!/bin/bash
source "$(dirname "$0")/heartbeat.conf"
S=$(date +%s)
until [ $(( $(date +%s) - S )) -ge 290 ] || grep -q "$DONE" "$RUNLOG" 2>/dev/null; do sleep 10; done
grep -q "$DONE" "$RUNLOG" 2>/dev/null && echo "$(date +%H:%M) | JOB DONE"
echo "$(date +%H:%M) | last step: $(tail -1 "$RUNLOG" 2>/dev/null | cut -c1-110) | checks: $(cat $RESULTS 2>/dev/null | grep -c '^PASS') passed, $(cat $RESULTS 2>/dev/null | grep -c '^FAIL') failed | running: $(ps -eo args | grep -cE "$PROCS") processes"
cat $RESULTS 2>/dev/null | grep '^FAIL' | cut -c1-200 | tail -5
