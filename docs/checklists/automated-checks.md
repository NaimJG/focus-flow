# Pre-Build Automated Verification Checks

These automated checks must ALL pass before building a release APK or AAB. Run them in order — each check verifies a different aspect of code quality and consistency.

## 1. Code Formatting

```bash
dart format . --set-exit-if-changed
```

**What it verifies:** All Dart source files conform to the canonical `dart format` style.

**Expected outcome:** Exit code 0, no files reformatted. If any file is reformatted, commit the formatting changes before proceeding.

## 2. Localization Files

```bash
flutter gen-l10n
```

**What it verifies:** Generated localization files (`app_localizations.dart`, `app_localizations_es.dart`, `app_localizations_en.dart`) are up to date with the `.arb` source files.

**Expected outcome:** No new or modified files in `lib/l10n/` or `.dart_tool/` after running. If files change, commit the updated localization output before proceeding.

## 3. Generated Code (build_runner)

```bash
dart run build_runner build --delete-conflicting-outputs
```

**What it verifies:** All code-generated files (Isar collections, JSON serialization, etc.) are current with their source annotations.

**Expected outcome:** No new or modified `.g.dart` files after running. If files change, commit the regenerated code before proceeding.

## 4. Static Analysis

```bash
flutter analyze
```

**What it verifies:** Zero lint warnings, errors, or info-level issues across the entire project.

**Expected outcome:** Output shows `No issues found!` with exit code 0. Fix all reported issues before proceeding.

## 5. Test Suite

```bash
flutter test
```

**What it verifies:** All unit tests, widget tests, and integration tests pass.

**Expected outcome:** All tests pass with exit code 0. Fix any failing tests before proceeding.

---

## Important

**All five checks must pass before building a release.** If any check fails, resolve the issue, re-run the failed check, and confirm it passes before moving to the build step.

### Suggested Workflow

```bash
dart format . --set-exit-if-changed \
  && flutter gen-l10n \
  && dart run build_runner build --delete-conflicting-outputs \
  && flutter analyze \
  && flutter test
```

If any command exits with a non-zero code, the chain stops and you can address the failure immediately.
