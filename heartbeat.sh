#!/bin/bash
source "$(dirname "$0")/heartbeat.conf"
while true; do
  sleep $EVERY
  step=$(tail -1 "$RUNLOG" 2>/dev/null | cut -c1-120)
  run=$(ps -eo args | grep -E "$PROCS" | cut -c1-60 | sort -u | tr '\n' ',' | sed 's/,$//; s/,/, /g')
  p=$(cat $RESULTS 2>/dev/null | grep -c '^PASS'); f=$(cat $RESULTS 2>/dev/null | grep -c '^FAIL')
  echo "- **$(date +%H:%M) (automatic, every $((EVERY / 60)) minutes):** last finished step: ${step:-none yet}. Running: ${run:-nothing}. Checks so far: $p passed, $f failed." >> "$PROGRESS"
  grep -q "$DONE" "$RUNLOG" 2>/dev/null && break
done
