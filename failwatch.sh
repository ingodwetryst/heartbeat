#!/bin/bash
source "$(dirname "$0")/heartbeat.conf"
n0=$(cat $RESULTS 2>/dev/null | grep -c '^FAIL')
until [ $(cat $RESULTS 2>/dev/null | grep -c '^FAIL') -gt $n0 ] || grep -q "$DONE" "$RUNLOG" 2>/dev/null; do sleep 60; done
date +%H:%M
cat $RESULTS 2>/dev/null | grep '^FAIL' | cut -c1-260 | tail -n +$((n0 + 1)) | head -20
tail -3 "$RUNLOG" 2>/dev/null
