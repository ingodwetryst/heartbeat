# Heartbeat for long Claude Code work

The heartbeat shows that long work (test runs, builds, batch jobs) is still alive, without you having to nanny it:

- **Progress log line.** `heartbeat.sh` runs in the background and adds one line to the bottom of the project's progress log every 5 minutes. It stops when the job writes its "done" text.
- **Chat status line.** Claude runs `tick.sh` as a background task. It finishes every 5 minutes, which wakes Claude up. Claude posts a one-line status in the chat and starts `tick.sh` again. When the job is done, Claude stops restarting it.

`failwatch.sh` is optional. It finishes as soon as a new FAIL shows up, so Claude hears about a failure right away instead of at the next 5-minute status.

## Files

- **heartbeat.md:** this guide.
- **heartbeat.conf:** the settings for one job.
- **heartbeat.sh:** writes the progress log line.
- **tick.sh:** wakes Claude for the chat status line.
- **failwatch.sh:** wakes Claude on a new FAIL.

## Set up on a new machine

1. Copy the whole `heartbeat` folder to `~/.claude/heartbeat` on that machine.
2. Make the scripts runnable: `chmod +x ~/.claude/heartbeat/*.sh`
3. Add the block below to your CLAUDE.md file

```markdown
## Long work: heartbeat

Any work that will take more than 15 minutes (test runs, builds, batch jobs, waiting on background processes) gets a heartbeat before it starts. The scripts and full instructions are in `~/.claude/heartbeat/` (read `heartbeat.md` there).

- Copy the `heartbeat` folder into the project folder and fill in `heartbeat.conf` for the job.
- Run `heartbeat.sh` in the background. Every 5 minutes it adds one line to the bottom of the project's progress log (for example `PROGRESS.md`): the time from the system clock, the last finished step, what is running now, and the pass and fail (or done and remaining) counts. It stops by itself when the work is done.
- Also post a one-line status in the chat every 5 minutes. Run `tick.sh` as a background task; when it finishes, post its first line as the status and start it again. Stop when it prints JOB DONE.
- Run `failwatch.sh` as a background task too, so new failures are reported as they happen.

The heartbeat lets me see the work is alive without asking. It does not replace reporting failures and fixes as they happen.
```

## How Claude uses it for a job

1. Copy the folder into the project: `cp -r ~/.claude/heartbeat ./heartbeat`
2. Fill in `heartbeat/heartbeat.conf`:
   - **RUNLOG:** the log the job writes to. Its last line is reported as the last finished step.
   - **RESULTS:** the result files. Lines that start with `PASS` or `FAIL` are counted.
   - **PROGRESS:** the progress log to append to, for example `PROGRESS.md`.
   - **PROCS:** a pattern that matches the job's processes in `ps -eo args`, for example `^node t-`. Start it with `^` so the pattern does not match the grep command itself.
   - **DONE:** the text the job writes to RUNLOG when it finishes, for example `ALL DONE`.
   - **EVERY:** seconds between progress log lines. 300 is 5 minutes.
3. Start the progress log line: `nohup ./heartbeat/heartbeat.sh >/dev/null 2>&1 &`
4. Start the chat timer: run `./heartbeat/tick.sh` with the Bash tool's background option. Each time it finishes, post its first line in the chat and start it again.
5. Optional: run `./heartbeat/failwatch.sh` the same way. When it finishes, report the new failures and start it again.

## Example lines

In the progress log:

```
- **09:13 (automatic, every 5 minutes):** last finished step: sites regenerated. Running: node t-ccheck.js chromium, node t-ccheck.js firefox. Checks so far: 22463 passed, 0 failed.
```

In the chat:

```
09:13 | last step: sites regenerated | checks: 22463 passed, 0 failed | running: 3 processes
```

## Stop it by hand

- Progress log line: `pkill -f heartbeat/heartbeat.sh`
- Chat timer and fail watcher: tell Claude to stop, or run `pkill -f heartbeat/tick.sh` and `pkill -f heartbeat/failwatch.sh`

## Limits

- The chat status only works while that Claude Code session is open. The progress log line keeps going on its own.
- Every chat status wakes Claude, so it uses a small amount of your usage limit every 5 minutes.
- If the job crashes without writing its DONE text, `heartbeat.sh` keeps adding lines until you stop it. The lines then show the same last step, which also shows the job is stuck.
- The counts only work if the job writes result lines that start with `PASS` and `FAIL`. For other jobs, change the two `grep -c` counts in the scripts to whatever the job writes, for example files done and remaining.
- The scripts use bash. They have only been run on Linux. On Windows, run them inside WSL.
