# Impression/Click Phoenix API (SWE Evaluation Repo)

This directory contains a **deliberately imperfect** Phoenix API used for Software Engineer test evaluation.

The app works, but it intentionally includes architectural and scalability flaws so candidates can identify issues, explain trade-offs, and propose/implement improvements.

## Purpose

This is not intended to be a production reference.
It is a baseline implementation for evaluating:

- debugging and refactoring skills
- architecture judgment
- API correctness thinking
- testing strategy
- communication of trade-offs

## Current Behavior

- `POST /events` accepts impression/click events.
- `GET /stats` returns minute-level aggregated stats for a campaign/time window.
- API is functional and tests pass.

## Local Setup

From this directory (`analytics/elixir_phoenix`):

```bash
docker compose up -d
mix setup
mix test
mix phx.server
```

## Notes for Evaluators

When reviewing submissions, focus on:

- reasoning quality (not only code output)
- correctness under realistic scenarios
- quality of trade-off decisions
- clarity of communication in PR/notes
