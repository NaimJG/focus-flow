# Focus Flow — Spec-Driven Development

## What is Spec-Driven Development?

Every non-trivial feature in Focus Flow is built through a three-phase specification process before any code is written. This prevents scope creep, surfaces design issues early, and produces a permanent record of decisions.

The three phases are:

1. **Requirements** — what the feature must do and why (user stories + acceptance criteria)
2. **Design** — how the feature will be built (architecture, data model, component breakdown)
3. **Tasks** — a sequenced implementation checklist derived from the design

## Spec File Location

```
.kiro/specs/<feature-name>/
├── requirements.md    # User stories and acceptance criteria
├── design.md          # Technical design and architecture decisions
└── tasks.md           # Ordered implementation checklist
```

Feature names use `kebab-case` and match the folder name under `lib/features/`.

## Requirements Phase

Requirements are written as **user stories** with **acceptance criteria** in EARS format:

```
### Requirement N: <Title>

**User Story:** As a <role>, I want <capability>, so that <benefit>.

#### Acceptance Criteria

1. WHEN <event> THEN the system SHALL <response>.
2. IF <condition> THEN the system SHALL <response>.
3. WHILE <state> THE system SHALL <constraint>.
```

Each acceptance criterion is independently verifiable. Vague criteria ("it should be fast", "it should look good") are not acceptable — they must be made concrete.

## Design Phase

The design document covers:

- **Overview** — one paragraph summary of the approach
- **Architecture** — how this feature fits into the existing structure
- **Data Model** — Isar collections, entities, value objects
- **Component Breakdown** — screens, widgets, use cases, repositories to be created
- **Correctness Properties** — formal properties the implementation must satisfy (used for property-based tests)
- **Open Questions** — decisions deferred to implementation with documented rationale

The design must not introduce patterns or abstractions that are not needed by v1.0.

## Tasks Phase

Tasks are a flat, ordered checklist. Each task:

- Is small enough to complete in one focused session
- Produces a working, testable increment
- References the requirement or design section it implements
- Includes property-based test tasks for any correctness properties defined in design

```markdown
- [ ] Task N: <description>
  - Implements: Requirement X / Design section Y
  - Deliverable: <what exists when this task is done>
```

## Correctness Properties

Each spec defines a set of correctness properties — formal, executable statements about system behavior. These become property-based tests.

**Example for Pomodoro:**
- `PROPERTY: forall duration > 0, a started timer eventually reaches zero`
- `PROPERTY: forall completed session, statistics total increases by exactly one`

Properties are listed in the design document and translated into test code during the Tasks phase.

## Principles for Spec Authors

- Write requirements before design. Do not let implementation assumptions leak into requirements.
- Acceptance criteria must be testable. If you cannot write a test for it, rewrite the criterion.
- The design doc is a decision record. Capture *why* a choice was made, not just *what* was chosen.
- Do not spec future features. Requirements and design reflect only what v1.0 needs.
- Prefer simple designs. If two approaches satisfy the requirements, choose the simpler one.
