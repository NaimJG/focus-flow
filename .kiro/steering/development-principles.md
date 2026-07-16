# Focus Flow — Development Principles

These principles apply to every line of code written in this project. They are not suggestions — they are the working standards that keep the codebase maintainable as it grows.

## General Principles

### Composition over Inheritance
Prefer composing small widgets and classes over creating deep inheritance hierarchies. Mixins are acceptable for shared behavior but should be kept focused.

### Single Responsibility
Each class, widget, use case, and function should do exactly one thing. If you find yourself writing "and" when describing what something does, it probably needs to be split.

### Keep Widgets Small
A widget that exceeds ~100–150 lines is a signal to extract sub-widgets. Screens orchestrate layout; they do not contain business logic or complex conditionals.

### Business Logic Outside the UI
Widgets render state and emit events. They do not contain computations, validations, or data transformations. All logic lives in use cases, controllers, or services.

### Immutability by Default
Prefer `final` fields and immutable value objects. Use `const` constructors wherever possible. Mutable shared state is a source of bugs.

### Descriptive Naming
Names should reveal intent. Avoid abbreviations, single-letter variables (except loop indices), and generic names like `data`, `manager`, or `helper`.

```dart
// Bad
final d = await repo.get(id);

// Good
final task = await taskRepository.findById(taskId);
```

### Avoid Duplication
Before creating a new utility or widget, check whether one already exists in `shared/` or `core/`. Extracting shared logic is always preferable to copy-pasting.

### Avoid Large Files
Files with more than ~200–250 lines should be reviewed for extraction opportunities. One public class per file.

### No Premature Abstraction
Do not create interfaces, factories, or base classes for things that only have one implementation. Add the abstraction when a second implementation actually exists or when testability requires it.

## Dart-Specific Practices

- Use `const` constructors for all widgets that have no runtime-variable state.
- Prefer named parameters for constructors with more than one parameter.
- Use `sealed` classes or enums for exhaustive state modeling.
- Avoid dynamic typing (`dynamic`, `Object` without casting). Use generics or explicit types.
- Leverage Dart's null safety — never use `!` (force-unwrap) without a documented reason.
- Use `extension` methods to add behavior to existing types rather than creating wrapper classes.

## Dependency Management

- Only add a package when it solves a real, present problem that would take significant effort to solve in-house.
- Prefer packages with strong pub.dev scores, active maintenance, and Flutter-official or well-established community status.
- Review the package's API surface before adding it — avoid packages that require deep coupling throughout the codebase.
- Use exact or tight version constraints (`^`) to keep builds reproducible.

## Error Handling

- Do not swallow exceptions silently. At minimum, log them.
- Use typed exceptions or `Result`-style return types for expected failure paths (e.g., "task not found").
- Unexpected errors should surface visibly during development (e.g., via `FlutterError.onError`).

## Testing Mindset

- Write code that is testable: inject dependencies, avoid global state, keep functions pure where possible.
- Use cases are the primary target for unit tests — they contain business logic and have no UI dependencies.
- Widget tests cover critical user interactions, not implementation details.
- Property-based testing (via `fast_check` or similar) is used for use cases and domain logic where input variety matters.
