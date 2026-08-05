# Data Safety Audit — Focus Flow 1.0.0

## Purpose

This document audits all dependencies in Focus Flow 1.0.0 for data collection and transmission behavior. It serves as the basis for completing the Google Play Console Data Safety form and ensures accurate declarations about user data practices.

**Audit date:** 2025-07-15

---

## Dependency Data Audit

| Package | Type | Collects Data? | Transmits Data? | Notes |
|---|---|---|---|---|
| `flutter` (SDK) | Framework | No | No | UI framework; no network or telemetry built-in |
| `flutter_localizations` (SDK) | Localization | No | No | Provides locale data bundled at compile time |
| `provider` ^6.1.2 | State management | No | No | Pure Dart package; manages in-memory state only |
| `isar` ^3.1.0+1 | Local database | No | No | Embedded database engine; all data stored on-device only |
| `isar_flutter_libs` ^3.1.0+1 | Native binaries for Isar | No | No | Platform-specific compiled libraries; no network capability |
| `path_provider` ^2.1.0 | File system paths | No | No | Returns local directory paths; no network operations |
| `intl` (any) | Internationalization | No | No | Pure Dart package; date/number formatting utilities |
| `cupertino_icons` ^1.0.8 | Icon assets | No | No | Static icon font bundled at compile time |
| `url_launcher` ^6.2.0 (planned) | URL opening | No | No | Opens external URLs in the system browser; see detailed note below |
| `audioplayers` ^6.1.0 | Audio playback | No | No | Plays bundled MP3 assets from local storage only; no network access required or used |

---

## url_launcher Behavior

The `url_launcher` package is included to allow users to open the privacy policy in an external browser. Important clarifications:

- `url_launcher` delegates URL opening to the operating system's default browser or app handler.
- It does **not** make network requests itself — it invokes an Android Intent.
- It does **not** collect, read, or transmit any app data.
- It does **not** track which URLs are opened or report analytics.
- The user initiates the action explicitly by tapping "Privacy Policy" in Settings.
- Any data exchange that occurs happens in the external browser, outside the app's process.

**Conclusion:** `url_launcher` is a local Intent launcher. The app itself does not collect or transmit data through this package.

---

## audioplayers Behavior

The `audioplayers` package (^6.1.0) is included to play short completion sounds when a Pomodoro session ends naturally. Important clarifications:

- `audioplayers` plays local asset files only (via `AssetSource`) — specifically `focus_complete.mp3` and `break_complete.mp3` bundled at build time.
- It does **not** require INTERNET permission for bundled asset playback.
- It does **not** collect analytics, telemetry, or user data.
- It does **not** transmit any data off-device.
- It does **not** include advertising SDKs.
- Used solely for playing two short bundled completion sounds (`focus_complete.mp3`, `break_complete.mp3`).

**Conclusion:** `audioplayers` is a local audio playback engine operating entirely on-device. It does not collect or transmit any data.

---

## INTERNET Permission

Focus Flow is an offline-first application with no network features:

- **No INTERNET permission** is declared in `src/main/AndroidManifest.xml` (the release manifest).
- `INTERNET` permission exists only in `src/debug/AndroidManifest.xml` and `src/profile/AndroidManifest.xml` for Flutter DevTools — these are **not merged into release builds**.
- No dependency in the production dependency tree requires or requests the INTERNET permission.
- The app performs no HTTP requests, no WebSocket connections, no cloud sync, and no telemetry.
- All user data is stored exclusively in the local Isar database on the device.

**Conclusion:** The release build contains no INTERNET permission and performs no network communication.

---

## Absent Packages — Notifications

The following notification packages are **not present** in `pubspec.yaml`:

- `flutter_local_notifications` — not included
- `firebase_messaging` — not included
- `awesome_notifications` — not included
- Any other push notification or local notification package — not included

Additionally:

- No `POST_NOTIFICATIONS` permission is declared in any manifest.
- No foreground service is implemented.
- No `ForegroundServiceType` is declared.
- No notification channels are registered.

**Conclusion:** The app has no notification capability of any kind.

---

## Absent Services — Analytics and Telemetry

- No Firebase SDK (firebase_core, firebase_analytics, firebase_crashlytics)
- No Sentry, Bugsnag, or third-party crash reporting
- No custom telemetry or usage tracking
- No advertising SDKs (AdMob, Unity Ads, etc.)
- No social login or authentication services

---

## Data Safety Form Conclusion

Based on this audit, the Google Play Data Safety form should be completed as follows:

| Question | Answer |
|---|---|
| Does your app collect any user data? | **No** |
| Does your app share any user data with third parties? | **No** |
| Does your app use encryption? | No (local database only, no data in transit) |
| Can users request data deletion? | N/A (uninstalling removes all local data) |

**Note:** Audio playback via `audioplayers` is entirely local (bundled asset files played from device storage) and does not affect the "No data collected, No data shared" declaration.

### Declaration Summary

> **"No data collected, No data shared"**

This declaration is accurate because:

1. All user data (tasks, Pomodoro sessions, statistics, settings) is stored exclusively in the local Isar database on the device.
2. No dependency transmits data off-device.
3. No analytics, crash reporting, or telemetry exists.
4. No advertisements are displayed.
5. No user accounts or authentication exists.
6. Audio playback uses `audioplayers` with bundled assets only (`AssetSource`); it introduces no new permissions and performs no network operations.
7. The only external interaction (`url_launcher`) is user-initiated and handled by the OS browser, not by the app.

---

## References

- Requirements: 6.4, 9.1, 9.2, 9.3, 9.4, 9.5, 10.7, 10.8, 20.1, 20.2, 20.3, 20.5
- Google Play Data Safety documentation: https://support.google.com/googleplay/android-developer/answer/10787469
