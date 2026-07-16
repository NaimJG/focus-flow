# Focus Flow — Project Overview

## What is Focus Flow?

Focus Flow is an offline-first Flutter productivity application targeting Android (Google Play). It helps users manage their work through three core modules:

- **Todo Lists** — task capture and management
- **Pomodoro Timer** — focused work sessions with structured breaks
- **Productivity Statistics** — insights derived from completed sessions and tasks

## Version 1.0 Scope

The first public release is intentionally minimal. It ships exactly four features and one support screen:

| Feature | Purpose |
|---|---|
| Home | Entry point and overview |
| Todo | Task creation and management |
| Pomodoro | Timer with work/break cycles |
| Statistics | Productivity data and charts |
| Settings | App-level preferences |

**No other features belong in Version 1.0.** Future capabilities (Goals, Achievements, Cloud Sync, Premium, Widgets, AI) must not influence current design decisions, abstractions, or data models.

## Product Philosophy

Every decision in this project is guided by five commitments:

1. **Offline First** — the app works fully without a network connection. Local persistence is the source of truth.
2. **Simplicity over complexity** — choose the simpler path unless there is a concrete, present reason not to.
3. **Incremental development** — ship small, stable, isolated increments. Never block progress on future uncertainty.
4. **Maintainability over cleverness** — readable, predictable code is more valuable than optimized or abstract code.
5. **Avoid premature optimization** — do not optimize what has not been measured as a problem.

## Target Platform

- Android (primary target, Google Play release)
- Flutter's cross-platform nature is preserved but iOS/Web/Desktop are not active targets for v1.0.
