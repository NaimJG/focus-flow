# Focus Flow — Code Style

## Naming Conventions

| Element | Convention | Example |
|---|---|---|
| Files and folders | `lower_snake_case` | `todo_repository.dart` |
| Classes, enums, typedefs | `PascalCase` | `TodoRepository` |
| Methods, functions, variables | `camelCase` | `fetchPendingTasks()` |
| Constants | `camelCase` (Dart style) | `const defaultDuration` |
| Private members | leading underscore + `camelCase` | `_isLoading` |

One public class per file. The file name must match the class name.

## File Organization

Within a file, follow this order:

1. Imports (dart:, package:, relative — each group separated by a blank line)
2. Constants and type aliases
3. The primary public class
4. Private helper classes or functions used only in this file

## Widget Conventions

```dart
// Prefer const constructors
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
  });

  final Task task;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) { ... }
}
```

- `key` is always the first parameter, passed to `super`.
- Required parameters come before optional ones.
- Callbacks use `VoidCallback`, `ValueChanged<T>`, or explicit `Function` signatures — no raw `Function`.

## Import Style

```dart
// 1. Dart SDK
import 'dart:async';

// 2. Flutter / pub packages
import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

// 3. Internal (relative paths)
import '../../domain/entities/task.dart';
```

Never use absolute `package:focus_flow/...` imports within the `lib/` tree — use relative imports for internal code.

## Comments and Documentation

- Public APIs (classes, methods visible outside their file) should have a `///` doc comment.
- Inline comments explain *why*, not *what*. If the code needs a comment to explain what it does, simplify the code first.
- Do not leave dead code or TODO comments in committed code unless they reference a tracked issue.

```dart
// Bad
// increment counter by 1
counter++;

// Good
// Debounce: wait for the user to stop typing before saving to avoid excessive writes.
_debounceTimer?.cancel();
_debounceTimer = Timer(const Duration(milliseconds: 500), _saveToDb);
```

## Formatting

- Use `dart format` (via `flutter format .`) as the canonical formatter. All committed code must be formatted.
- Maximum line length: 80 characters (Dart default).
- No trailing whitespace.
- Trailing commas on multi-line parameter lists and collections — they produce cleaner diffs.

```dart
// Good: trailing comma keeps each param on its own line in formatted output
return ElevatedButton(
  onPressed: onTap,
  child: Text(label),
);
```
