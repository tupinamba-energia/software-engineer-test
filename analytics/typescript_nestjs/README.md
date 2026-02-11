# Impression/Click NestJS API (SWE Evaluation Repo)

This directory is a **deliberately imperfect** NestJS version of the impression/click challenge used for Software Engineer evaluation.

The app works, but it intentionally contains weak architecture and coupling so candidates can identify and improve it.

## Purpose

This is an evaluation baseline, not production reference code.

It is useful to assess:

- debugging/refactoring ability
- architecture judgment
- API correctness reasoning
- test strategy
- communication of trade-offs

## Current API

- `POST /events`
- `GET /stats?campaign_id=<id>&from=<iso>&to=<iso>&granularity=minute`

## Local Setup

From `analytics/typescript_nestjs`:

```bash
docker compose up -d
npm install
npm run prisma:migrate
npm run test:e2e
npm run start:dev
```

If migration fails on a fresh local environment, fallback to:

```bash
npm run prisma:push
```

## Notes for Evaluators

Focus review on candidate reasoning and improvements, not just code output.
Typical improvements to expect:

- move logic from controllers to service/domain layers
- improve validation and error consistency
- improve query strategy for stats
- add constraints/indexes and idempotency strategy
- expand test coverage for edge cases and concurrency
