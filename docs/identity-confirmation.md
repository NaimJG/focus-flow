# Application Identity Confirmation

## Why This Matters

The **applicationId** is the permanent, unique identifier for your app on Google Play. Once the first AAB is uploaded to Play Console, the applicationId **cannot be changed**. A different applicationId means a completely different app listing — existing users cannot migrate.

This document records the current identity configuration and a known discrepancy that must be resolved before release.

---

## Current Configuration

| Property | Value | Location |
|---|---|---|
| `applicationId` | `com.ncambe.focus_flow` | `android/app/build.gradle.kts` |
| `namespace` | `com.ncambe.focus_flow` | `android/app/build.gradle.kts` |
| `android:label` | `Focus Flow` | `android/app/src/main/AndroidManifest.xml` |
| `MainActivity.kt` package declaration | `package com.ncambe.focus_flow` | Line 1 of `MainActivity.kt` |
| `MainActivity.kt` file path | `android/app/src/main/kotlin/com/example/focus_flow/` | Filesystem |

---

## Known Discrepancy: MainActivity.kt Path

There is a mismatch between the **file path** and the **package declaration** of `MainActivity.kt`:

- **File path:** `android/app/src/main/kotlin/com/example/focus_flow/MainActivity.kt`
- **Package declaration inside the file:** `package com.ncambe.focus_flow`

The file lives under `com/example/focus_flow/` (the Flutter project creation default) but declares itself as belonging to the `com.ncambe.focus_flow` package. This works at build time because Kotlin does not enforce directory-to-package correspondence the way Java does, but it is inconsistent and should be corrected.

### Resolution

The applicationId is confirmed as `com.ncambe.focus_flow`. Relocate `MainActivity.kt` to match the confirmed package structure:

- Move from: `android/app/src/main/kotlin/com/example/focus_flow/MainActivity.kt`
- Move to: `android/app/src/main/kotlin/com/ncambe/focus_flow/MainActivity.kt`
- Delete the now-empty `com/example/focus_flow/` directory

---

## App Label Verification

The `android:label` attribute in `android/app/src/main/AndroidManifest.xml` is already set to:

```xml
android:label="Focus Flow"
```

This is correct and requires no changes. This label is what appears on the device launcher and in the system app list.

---

## Confirmation

The applicationId `com.ncambe.focus_flow` was confirmed on **2026-08-03**. This is the permanent identity for the app on Google Play.

---

## Confirmation Checklist

Please confirm the following before proceeding with release preparation:

- [x] **Final applicationId:** `com.ncambe.focus_flow`
- [x] **Final namespace:** `com.ncambe.focus_flow`
- [x] **App label:** "Focus Flow" (already set — confirm this is correct)
- [x] **Acknowledged:** The applicationId is permanent after first Play Store upload and cannot be changed

✅ Confirmed on 2026-08-03

### Candidates

| Candidate | Notes |
|---|---|
| `com.ncambe.focus_flow` | Current value. Uses underscore (valid but uncommon in reverse-domain convention). ✅ **CONFIRMED** |
| `com.ncambe.focusflow` | No underscore. More conventional for Android package names. Would require updating `build.gradle.kts`, `MainActivity.kt` package, and creating new directory structure. |
| `com.naimcambe.focusflow` | Alternative domain prefix if `ncambe` is abbreviated. |

### Pending Changes

The following changes are ready to be applied:

1. Relocate `MainActivity.kt` to the correct package directory (`com/ncambe/focus_flow/`)
2. Delete the old `com/example/focus_flow/` directory

---

## References

- [Android Application ID documentation](https://developer.android.com/studio/build/application-id)
- [Google Play applicationId permanence](https://developer.android.com/studio/build/application-id#change_the_application_id)
- Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6
