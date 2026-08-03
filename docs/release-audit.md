# Release Configuration Audit — Focus Flow 1.0.0

**Audit date:** 2025-01-27
**File audited:** `android/app/build.gradle.kts`
**Status:** Pre-release (configuration uses defaults and debug signing)

---

## 1. Application Identity

| Property | Value | Status |
|---|---|---|
| `applicationId` | `com.ncambe.focus_flow` | ✅ Set (pending user confirmation — permanent after first Play Store upload) |
| `namespace` | `com.ncambe.focus_flow` | ✅ Set (consistent with applicationId) |

> **Note:** The applicationId is currently `com.ncambe.focus_flow`. This value is **permanent** once the first AAB is uploaded to Google Play. Explicit user confirmation is required before release.

---

## 2. SDK Configuration

All SDK values are Flutter-managed (resolved at build time from the Flutter SDK):

| Property | Value | Status |
|---|---|---|
| `compileSdk` | `flutter.compileSdkVersion` | ✅ Flutter-managed |
| `targetSdk` | `flutter.targetSdkVersion` | ✅ Flutter-managed |
| `minSdk` | `flutter.minSdkVersion` | ✅ Flutter-managed |
| `ndkVersion` | `flutter.ndkVersion` | ✅ Flutter-managed |

> **Action needed:** Verify that `flutter.compileSdkVersion` and `flutter.targetSdkVersion` resolve to API 36+ (Google Play requirement by Aug 31, 2026). If they resolve to <36, an explicit override will be added.

---

## 3. Version Configuration

| Property | Value | Status |
|---|---|---|
| `versionCode` | `flutter.versionCode` | ✅ Flutter-managed (from `pubspec.yaml` build number) |
| `versionName` | `flutter.versionName` | ✅ Flutter-managed (from `pubspec.yaml` version string) |

Version values are derived from `pubspec.yaml`'s `version` field. For `version: 1.0.0+1`:
- `versionName` → `1.0.0`
- `versionCode` → `1`

---

## 4. Signing Configuration

| Property | Current Value | Status |
|---|---|---|
| Release signing | `signingConfigs.getByName("debug")` | ⚠️ Uses debug key — must be replaced before release |

The release build type currently signs with the debug keystore. Before Play Store submission, this must be replaced with a dedicated upload key via `signingConfigs.create("release")` loaded from `key.properties`.

---

## 5. TODOs in `build.gradle.kts`

Two TODO comments exist in the file:

1. **Line 16 (applicationId):**
   ```
   // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
   ```
   Status: The applicationId has been set to `com.ncambe.focus_flow`. This TODO can be removed once the user confirms the final value.

2. **Line 27 (signing config):**
   ```
   // TODO: Add your own signing config for the release build.
   // Signing with the debug keys for now, so `flutter run --release` works.
   ```
   Status: Must be resolved by configuring a dedicated upload key before release.

---

## 6. MainActivity.kt Path Discrepancy

| Aspect | Value |
|---|---|
| File location | `android/app/src/main/kotlin/com/example/focus_flow/MainActivity.kt` |
| Package declaration | `package com.ncambe.focus_flow` |

**Discrepancy:** The file physically resides in the `com/example/focus_flow/` directory structure, but declares `package com.ncambe.focus_flow`. This mismatch was likely caused by the initial `flutter create` using `com.example.focus_flow` and a later manual update to the package declaration without relocating the file.

**Impact:** This works at build time because Kotlin/Gradle resolves packages via the declaration, not the directory path. However, it is a maintenance concern and violates standard Java/Kotlin package conventions.

**Action needed:** When the applicationId is confirmed, relocate `MainActivity.kt` to a directory matching the package:
- If confirmed as `com.ncambe.focus_flow` → move to `com/ncambe/focus_flow/MainActivity.kt`

---

## 7. Kotlin Configuration

| Property | Value |
|---|---|
| JVM target | `JVM_17` |
| Source compatibility | `JavaVersion.VERSION_17` |
| Target compatibility | `JavaVersion.VERSION_17` |

No issues — consistent JVM 17 target across compile options and Kotlin compiler.

---

## 8. Summary of Required Actions Before Release

| # | Action | Priority | Blocked By |
|---|---|---|---|
| 1 | Confirm final applicationId with user | Critical | User decision |
| 2 | Relocate `MainActivity.kt` to correct package path | High | Action #1 |
| 3 | Configure release signing (`key.properties` + `signingConfigs.release`) | Critical | Keystore generation |
| 4 | Verify SDK targets resolve to API 36+ | Medium | Flutter SDK version check |
| 5 | Remove resolved TODO comments | Low | Actions #1, #3 |
| 6 | Enable R8/ProGuard for release | Medium | ProGuard rules creation |
