---
name: daydream
description: Use when the user asks to daydream the Obsidian vault, run /daydream, or find non-obvious connections between notes. Samples recent note pairs, synthesizes connections, scores them, and writes insight notes plus a daily digest.
---

# Vault Daydream Skill

Multi-agent system that mines the Obsidian vault for non-obvious connections between notes, mimicking the brain's default mode network. Samples random note pairs, synthesizes connections with `task(subagent_type: "general")`, then filters them with a second `general` critic pass.

Inspired by [Gwern's LLM Daydreaming](https://gwern.net/ai-daydreaming).

## Usage

Ask the agent to run daydream on the vault. See `instructions.md` for the exact procedure.

## What it does

1. Auto-detects vault root from current directory (asks if not found)
2. Scans vault for notes modified in last 120 days
3. Generates 50 recency-weighted random pairs
4. Synthesizes connections (parallel `general` subagent batches of 5)
5. Critiques and scores insights (parallel `general` subagent batches)
6. Filters for quality (average score >= 7.0)
7. Saves insight notes to `Daydreams/` folder
8. Generates daily digest in `Daydreams/digests/`
9. Appends summary to today's daily note

## Output

- **Individual insights**: `Daydreams/YYYYMMDD-slug.md` -- full synthesis with scores and wikilinks
- **Daily digest**: `Daydreams/digests/YYYYMMDD-digest.md` -- stats + ranked top insights
- **Daily note**: Summary appended under `## Daydream`
- **History log**: `ai-research/daydream/history.json` -- tracks sampled pairs for dedup

## Architecture

Skill (orchestrator)
  |-- Glob/Read: scan vault, extract excerpts
  |-- Generate 50 random pairs (recency-weighted)
  |-- task(subagent_type: "general") x 10: synthesize connections  <-- parallel
  |-- task(subagent_type: "general") x 10: critique/score insights <-- parallel
  |-- Filter (avg >= 7.0)
  +-- Write: save insight notes + daily digest

No external dependencies -- pure opencode tools (Glob, Read, Write, Bash, task, question).

## Notes

- opencode's `task` tool has no per-task model selector, so synthesis and critique both run on `general` subagents (no Sonnet/Haiku split).
- Skills are loaded once at opencode startup: restart opencode after editing this file.
