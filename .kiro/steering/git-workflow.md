# Focus Flow — Git Workflow

## Branch Strategy

| Branch pattern | Purpose |
|---|---|
| `main` | Stable, releasable code. Direct commits are not allowed. |
| `feature/<feature-name>` | New features or enhancements |
| `bugfix/<bug-name>` | Bug fixes |
| `release/<version>` | Release preparation (version bump, changelog) |
| `chore/<topic>` | Dependency updates, build config, tooling |

All work happens on a branch. Merges to `main` go through a pull request.

## Commit Conventions

This project uses [Conventional Commits](https://www.conventionalcommits.org/).

**Format:**
```
<type>(<scope>): <short description>

[optional body]

[optional footer]
```

**Types:**

| Type | When to use |
|---|---|
| `feat` | A new feature visible to the user |
| `fix` | A bug fix |
| `refactor` | Code restructuring with no behavior change |
| `test` | Adding or updating tests |
| `docs` | Documentation only changes |
| `chore` | Build process, dependency, or tooling changes |
| `style` | Formatting only (no logic change) |
| `perf` | Performance improvement |

**Scope** (optional but recommended): the feature or module affected.

```
feat(todo): add swipe-to-delete on task list
fix(pomodoro): timer does not reset after session end
refactor(core): extract isar initialization into DatabaseService
```

**Rules:**
- Subject line is lowercase, no period at the end.
- Commits are small and focused — one logical change per commit.
- Do not bundle unrelated changes in the same commit.
- The body explains *why*, not *what* (the diff shows what).

## Pull Request Guidelines

- PR title follows the same Conventional Commits format as commits.
- Description includes: what changed, why, and any testing notes.
- PRs should be small enough to review in one sitting (~400 lines of diff as a soft ceiling).
- All CI checks must pass before merging.
- Squash merge into `main` to keep history linear and clean.

## Versioning

The project follows [Semantic Versioning](https://semver.org/) expressed in `pubspec.yaml`:

```
version: <major>.<minor>.<patch>+<build_number>
```

- **Patch** (`1.0.x`): bug fixes, no new features.
- **Minor** (`1.x.0`): new backward-compatible features.
- **Major** (`x.0.0`): breaking changes or major product pivots.
- **Build number**: increments with every Play Store submission.

v1.0.0 is the target for the first Google Play release.
