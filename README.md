# Heartbeat

The heartbeat shows that long Claude Code work is still alive, without you having to nanny it. `heartbeat.sh` runs in the background and adds one line to the bottom of the project's progress log every 5 minutes: the time, the last finished step, what is running and the pass and fail counts. It stops when the job writes its "done" text. Claude also runs `tick.sh` as a background task that finishes every 5 minutes. Each time it finishes, Claude posts a one-line status in the chat and starts it again. `failwatch.sh` wakes Claude as soon as a new FAIL appears, so failures are reported right away. All three scripts read their paths and settings from `heartbeat.conf`.

## Files

- **heartbeat.md:** how to set it up on a new machine, the block to paste your CLAUDE.md, the steps Claude follows for each job, and how to stop it.
- **heartbeat.conf:** the settings for one job: log paths, process pattern, "done" text and how often it runs.
- **heartbeat.sh:** writes the progress log line every 5 minutes.
- **tick.sh:** wakes Claude every 5 minutes to post the chat status line. Prints "JOB DONE" when the job has finished.
- **failwatch.sh:** wakes Claude when a new FAIL appears. Optional.

## Limits

The chat status line depends on Claude Code relaunching `tick.sh` each time it finishes. It only works while that session is open, and each wake-up uses a small amount of your usage limit (usually 250-500 tokens).
