# Implementation Plan: Release Preparation (Focus Flow 1.0.0)

## Overview

This plan covers all configuration, documentation, and verification work to prepare Focus Flow 1.0.0 for Google Play Store submission. Tasks are ordered to build incrementally — identity first, then signing, then documentation, then build verification. Code tasks produce configuration and a single privacy-policy widget; documentation tasks produce markdown artifacts in `docs/`. Manual Play Console steps are clearly labeled.

## Tasks

- [x] 1. Audit current release configuration
  - [x] 1.1 Document the current state of `android/app/build.gradle.kts` including applicationId, namespace, SDK values, signing config, and any TODOs
    - Confirm `applicationId = "com.ncambe.focus_flow"`, `namespace = "com.ncambe.focus_flow"`
    - Confirm Flutter-managed SDK values (`flutter.compileSdkVersion`, `flutter.targetSdkVersion`, `flutter.minSdkVersion`)
    - Confirm release signing currently uses debug key
    - Document the `MainActivity.kt` path discrepancy: file at `com/example/focus_flow/` but package declares `com.ncambe.focus_flow`
    - Output: comment/note in `docs/checklists/automated-checks.md` (created later) or inline documentation
    - _Requirements: 1.6, 2.1, 2.2, 3.3_

- [x] 2. Confirm applicationId and release identity
  - [x] 2.1 Create `docs/identity-confirmation.md` documenting the applicationId decision and its permanence
    - Document the current applicationId `com.ncambe.focus_flow`
    - Document the namespace `com.ncambe.focus_flow`
    - Document the `MainActivity.kt` path discrepancy (`com/example/focus_flow/` vs `com.ncambe.focus_flow`)
    - Use placeholder `[APPLICATION_ID]` until user confirms
    - Note: if confirmed as `com.ncambe.focus_flow`, relocate `MainActivity.kt` from `com/example/focus_flow/` to `com/ncambe/focus_flow/`
    - Verify `android:label="Focus Flow"` in `android/app/src/main/AndroidManifest.xml` (already set)
    - File: `docs/identity-confirmation.md`
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

- [x] 3. Checkpoint — applicationId confirmation
  - Ensure the user has confirmed the final applicationId before proceeding. The applicationId is permanent after first Play Store upload. Ask the user if questions arise.

- [x] 4. Configure version and Android SDK
  - [x] 4.1 Verify version configuration in `pubspec.yaml` and `build.gradle.kts`
    - Confirm `pubspec.yaml` has `version: 1.0.0+1`
    - Confirm `build.gradle.kts` uses `flutter.versionCode` and `flutter.versionName` (already the case)
    - Document that `1.0.0` → `versionName`, `1` → `versionCode`
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 4.2 Verify or override SDK target to API 36+
    - Check if `flutter.compileSdkVersion` and `flutter.targetSdkVersion` resolve to ≥36
    - If already ≥36: no changes needed (keep Flutter-managed values)
    - If <36: add conditional override in `build.gradle.kts`:
      ```kotlin
      compileSdk = if ((flutter.compileSdkVersion as Int) >= 36) flutter.compileSdkVersion else 36
      targetSdk = if ((flutter.targetSdkVersion as Int) >= 36) flutter.targetSdkVersion else 36
      ```
    - Keep `minSdk = flutter.minSdkVersion` unchanged
    - File: `android/app/build.gradle.kts`
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [x] 5. Configure secure signing
  - [x] 5.1 Create `android/app/key.properties.example` template
    - Content:
      ```properties
      storeFile=../keystores/upload-keystore.jks
      storePassword=<YOUR_STORE_PASSWORD>
      keyAlias=upload
      keyPassword=<YOUR_KEY_PASSWORD>
      ```
    - This file IS committed to Git as a reference
    - File: `android/app/key.properties.example`
    - _Requirements: 4.3, 4.7_

  - [x] 5.2 Create `android/app/proguard-rules.pro` with Flutter and Isar keep rules
    - Add Flutter keep rules (`io.flutter.**`, `io.flutter.embedding.**`)
    - Add Isar keep rules (`dev.isar.**`)
    - File: `android/app/proguard-rules.pro`
    - _Requirements: 5.6_

  - [x] 5.3 Update `android/app/build.gradle.kts` with signing configuration
    - Add `import java.util.Properties` and `import java.io.FileInputStream`
    - Add `key.properties` loading logic with `GradleException` if file missing
    - Add `signingConfigs.create("release")` block reading from `keystoreProperties`
    - Change `buildTypes.release.signingConfig` from debug to `signingConfigs.getByName("release")`
    - Add `isMinifyEnabled = true` and `isShrinkResources = true` in release block
    - Add ProGuard file references
    - File: `android/app/build.gradle.kts`
    - _Requirements: 4.1, 4.3, 4.4, 4.5, 4.7, 4.8, 5.6_

  - [x] 5.4 Document keystore generation and backup procedure
    - Document the `keytool` command (RSA 2048-bit, 10000-day validity, alias "upload")
    - Document secure storage locations (encrypted cloud, hardware backup)
    - Document password manager procedure for credentials
    - Document Google Play App Signing enrollment (on first upload)
    - Note: NEVER generate or store real passwords in any committed file
    - File: `docs/checklists/signing-setup.md`
    - _Requirements: 4.2, 4.6, 4.9, 4.10_

- [x] 6. Checkpoint — signing configuration
  - Ensure the signing configuration compiles correctly (user must create actual `key.properties` locally). Ask the user if questions arise.

- [x] 7. Audit permissions and dependencies
  - [x] 7.1 Create `docs/checklists/data-safety-audit.md` with dependency data audit
    - Audit each dependency: flutter SDK, provider, isar, isar_flutter_libs, path_provider, intl, flutter_localizations, cupertino_icons, url_launcher
    - Document that none transmit data off-device
    - Document that `url_launcher` opens external URLs but does not collect/transmit app data
    - Document that no INTERNET permission is needed (offline-first, no network features)
    - Document absence of audio packages and notification packages
    - Conclude: "No data collected, No data shared" for Data Safety form
    - File: `docs/checklists/data-safety-audit.md`
    - _Requirements: 6.4, 9.1, 9.2, 9.3, 9.4, 9.5, 20.1, 20.2, 20.3, 20.5_

  - [x] 7.2 Verify release manifest permissions and add removal rule if needed
    - Confirm `src/main/AndroidManifest.xml` declares no INTERNET or POST_NOTIFICATIONS
    - Confirm `src/debug/AndroidManifest.xml` and `src/profile/AndroidManifest.xml` add INTERNET (debug-only, not merged to release)
    - If any dependency contributes unexpected permissions: add `tools:node="remove"` rule
    - File: `android/app/src/main/AndroidManifest.xml` (only if changes needed)
    - _Requirements: 6.1, 6.2, 6.3, 6.5_

- [x] 8. Create privacy-policy documents
  - [x] 8.1 Create `docs/privacy-policy.md` with Spanish (primary) and English sections
    - State: app operates entirely offline, no network communication
    - State: no user accounts, authentication, or registration
    - State: no analytics, crash reporting, or telemetry
    - State: no advertisements
    - State: no data shared with third parties
    - State: all data stored exclusively on local device
    - Include placeholder `[DEVELOPER_EMAIL]` for contact email
    - Include date of last update
    - File: `docs/privacy-policy.md`
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9, 7.10_

- [x] 9. Add in-app privacy-policy access
  - [x] 9.1 Add `url_launcher` dependency to `pubspec.yaml`
    - Add `url_launcher: ^6.2.0` under dependencies
    - Run `flutter pub get`
    - File: `pubspec.yaml`
    - _Requirements: 8.3_

  - [x] 9.2 Create `lib/core/constants/app_urls.dart` with centralized URL constant
    - Define `abstract final class AppUrls` with `static const String privacyPolicy = '[PRIVACY_POLICY_URL]'`
    - File: `lib/core/constants/app_urls.dart`
    - _Requirements: 8.4, 8.5_

  - [x] 9.3 Add privacy-policy localization strings to ARB files
    - Add `settingsSectionPrivacy`: "Privacidad" / "Privacy"
    - Add `settingsPrivacyPolicy`: "Política de privacidad" / "Privacy policy"
    - Add `settingsPrivacyPolicyError`: "No se pudo abrir la política de privacidad" / "Could not open privacy policy"
    - Run `flutter gen-l10n`
    - Files: `lib/l10n/app_es.arb`, `lib/l10n/app_en.arb`
    - _Requirements: 8.2, 8.7_

  - [x] 9.4 Create `lib/features/settings/presentation/widgets/privacy_policy_section.dart`
    - Widget renders a section header "Privacy" and a `ListTile` with trailing external-link icon
    - On tap: launches `AppUrls.privacyPolicy` via `url_launcher` with `LaunchMode.externalApplication`
    - On failure: shows localized SnackBar error
    - Does NOT introduce a new controller
    - File: `lib/features/settings/presentation/widgets/privacy_policy_section.dart`
    - _Requirements: 8.1, 8.2, 8.6, 8.7_

  - [x] 9.5 Integrate `PrivacyPolicySection` into `SettingsScreen`
    - Add import for `privacy_policy_section.dart`
    - Add `PrivacyPolicySection()` as the last item in `_LoadedBody`'s `ListView` (after `SoundSettingsSection`)
    - File: `lib/features/settings/presentation/screens/settings_screen.dart`
    - _Requirements: 8.1_

  - [x] 9.6 Add `<queries>` intent for `url_launcher` in AndroidManifest.xml
    - Add `<intent>` with `android.intent.action.VIEW` and `android:scheme="https"` to existing `<queries>` block
    - File: `android/app/src/main/AndroidManifest.xml`
    - _Requirements: 8.2, 8.3_

  - [ ]* 9.7 Write widget test for `PrivacyPolicySection`
    - Test: section renders with correct localized text
    - Test: tapping ListTile calls `launchUrl` with `AppUrls.privacyPolicy`
    - Test: when `launchUrl` returns false, SnackBar is displayed
    - _Requirements: 8.2, 8.7_

- [x] 10. Checkpoint — privacy policy and URL confirmation
  - Ensure privacy policy document is created and the privacy-policy section renders in Settings. Confirm with user that the placeholder URL will be replaced before release. Ask the user if questions arise.

- [x] 11. Prepare Data Safety assessment
  - [x] 11.1 Finalize data safety documentation for Play Console submission
    - Summarize audit from task 7.1 into Play Console form answers
    - Document: "No data collected", "No data shared"
    - Document: `url_launcher` opens external URLs but app itself does not collect data
    - Document: no ads, no analytics, no crash reporting
    - Document: `soundEnabled` setting exists in domain model but no audio playback is implemented (no audio packages)
    - Document: no notification permissions or packages
    - File: `docs/checklists/data-safety-audit.md` (append Play Console form section)
    - _Requirements: 9.3, 10.2, 10.3, 20.1, 20.4, 20.5_

- [x] 12. Prepare store-listing text
  - [x] 12.1 Create `docs/store-listing/es-AR.md` with Spanish store listing
    - App name: "Focus Flow"
    - Short description (≤80 chars): Spanish
    - Full description: Spanish — accurately describe Todo, Pomodoro, Statistics features
    - Category: Productivity
    - Developer email: `[DEVELOPER_EMAIL]`
    - Privacy policy URL: `[PRIVACY_POLICY_URL]`
    - Must NOT claim features that don't exist (notifications, cloud sync, sound, social)
    - File: `docs/store-listing/es-AR.md`
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.9, 20.4_

  - [x] 12.2 Create `docs/store-listing/en-US.md` with English store listing
    - Same structure as es-AR.md but in English
    - File: `docs/store-listing/en-US.md`
    - _Requirements: 12.2, 12.3_

  - [x] 12.3 Create `docs/release-notes/1.0.0.md` with release notes
    - Version 1.0.0 release notes in Spanish (primary) and English
    - Describe initial release features: Todo management, Pomodoro timer, Statistics, Settings
    - File: `docs/release-notes/1.0.0.md`
    - _Requirements: 12.7, 12.8_

- [x] 13. Prepare store assets checklist
  - [x] 13.1 Create `docs/store-listing/assets-checklist.md` documenting all required visual assets
    - 512×512 app icon (PNG) — source from existing launcher icon
    - 1024×500 feature graphic (PNG) — must be created/designed
    - Phone screenshots list: Todo list, Task form, Pomodoro running, General statistics, Per-task statistics, Settings
    - Screenshots in Spanish (primary), English (optional)
    - Note: screenshots must NOT show debug banner (use `--release` or `--profile` build)
    - Note: screenshots must show realistic but non-personal data
    - File: `docs/store-listing/assets-checklist.md`
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5, 13.6, 13.7_

- [x] 14. Build and verify signed release APK
  - [x] 14.1 Create `docs/checklists/automated-checks.md` with pre-build verification commands
    - Document: `dart format .` — confirm no formatting changes
    - Document: `flutter gen-l10n` — confirm localization files current
    - Document: `dart run build_runner build --delete-conflicting-outputs` — confirm generated code current
    - Document: `flutter analyze` — confirm zero issues
    - Document: `flutter test` — confirm all tests pass
    - Note: all checks must pass before building release
    - File: `docs/checklists/automated-checks.md`
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6_

  - [x] 14.2 Run automated checks (`dart format`, `flutter gen-l10n`, `build_runner`, `flutter analyze`, `flutter test`)
    - Execute each command and fix any issues found
    - All must pass before proceeding to APK build
    - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5, 15.6_

  - [x] 14.3 Build release APK with `flutter build apk --release`
    - Verify build completes without errors
    - Verify APK is signed with upload key (not debug): `apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk`
    - _Requirements: 16.1, 16.6, 5.1_

- [x] 15. Checkpoint — signed APK installation
  - MANUAL: Install the release APK on a physical device. Verify: app name "Focus Flow", launcher icon, splash screen, no debug banner, data persistence, privacy policy link works. Ask the user if questions arise.
  - _Requirements: 16.2, 16.3, 16.4, 16.5, 5.3, 5.4, 5.8_

- [x] 16. Build and verify signed AAB
  - [x] 16.1 Build release AAB with `flutter build appbundle --release`
    - Verify build completes without errors
    - Verify AAB contains correct applicationId, versionName `1.0.0`, versionCode `1`
    - Verify AAB targets API 36+
    - Document expected file size range
    - Verify no secrets/keystore content in the bundle
    - _Requirements: 17.1, 17.2, 17.3, 17.4, 17.5, 17.6, 17.7_

- [x] 17. Checkpoint — signed AAB generation
  - Ensure AAB is generated successfully with correct metadata. Ask the user if questions arise.
  - _Requirements: 17.7_

- [x] 18. Create manual verification checklist
  - [x] 18.1 Create `docs/checklists/verification-checklist.md` with full manual QA checklist
    - App startup: correct name, icon, splash
    - Language switching: Spanish ↔ English
    - Todo CRUD: create, read, update, delete
    - Pomodoro: start, pause, complete work session, break session
    - Statistics: display accuracy after Pomodoro sessions
    - Settings: persistence across app restarts
    - Privacy policy link: opens in external browser
    - Offline operation: works fully without network
    - Data survival: data persists after process kill and restart
    - Layout: integrity at 360dp width (small phone)
    - Text scaling: readable at 200% system text scaling
    - Themes: correct appearance in light and dark themes
    - Devices: test on at least one physical device and one emulator
    - File: `docs/checklists/verification-checklist.md`
    - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 14.6, 14.7, 14.8, 14.9, 14.10, 14.11, 14.12, 14.13_

- [x] 19. Internal testing checklist
  - [x] 19.1 Create `docs/play-console/upload-workflow.md` with complete Play Console guide
    - Step-by-step: create app entry, set up store listing, upload AAB
    - Complete content declarations: privacy policy URL, Data Safety form, ads, app access, content rating, target audience
    - Document Google Play App Signing enrollment
    - Document closed testing track setup (12+ testers, 14-day requirement for new personal accounts)
    - Document transition from closed testing to production release
    - Document expected review timelines and common rejection reasons
    - MANUAL: All Play Console steps must be performed by the user in browser
    - File: `docs/play-console/upload-workflow.md`
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 11.1, 11.2, 11.3, 11.4, 18.1, 18.2, 18.3, 18.4, 18.5, 18.6_

- [ ] 20. Checkpoint — internal testing
  - MANUAL: Ensure closed testing track is set up (if required by account type), testers are added, and the 14-day countdown has begun. Ask the user if questions arise.
  - _Requirements: 11.1, 11.2, 11.3_

- [ ] 21. Closed-testing and production-access checklist
  - [ ] 21.1 Document the closed-to-production transition in `docs/play-console/upload-workflow.md`
    - Append section: monitoring the 14-day closed testing period
    - Append section: requesting production access after testing completes
    - Append section: submitting for production review
    - MANUAL: User monitors and promotes via Play Console
    - File: `docs/play-console/upload-workflow.md` (append)
    - _Requirements: 11.2, 18.5_

- [ ] 22. Final production release and Git tag
  - [ ] 22.1 Document Git release workflow in `docs/play-console/upload-workflow.md`
    - Document: create Git tag `v1.0.0` ONLY after AAB is confirmed uploaded to Play Console
    - Document: do NOT tag before upload confirmation
    - Document: merge `chore/release-preparation` into `main` via PR after production submission
    - Document: Conventional Commits format for all commits
    - Suggested commit groups: identity config, signing setup, privacy policy, store listing, build verification
    - File: `docs/play-console/upload-workflow.md` (append)
    - _Requirements: 19.1, 19.2, 19.3, 19.4, 19.5, 19.6_

- [ ] 23. Checkpoint — final production upload
  - MANUAL: Ensure AAB is uploaded to Play Console, all declarations are complete, production review is submitted, and `v1.0.0` tag is created. Ask the user if questions arise.
  - _Requirements: 19.3, 19.4_

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure explicit user confirmation at critical decision points
- MANUAL labels indicate Play Console or physical device work that cannot be automated by a coding agent
- Placeholders `[APPLICATION_ID]`, `[DEVELOPER_EMAIL]`, `[PRIVACY_POLICY_URL]` must be replaced by user-confirmed values before release
- Security: no task generates, stores, or displays real keystore passwords — only placeholder templates
- Optional items (code obfuscation split symbols, golden tests, CI/CD deployment) are not included — they are out of scope per Requirement 21
- The `android/.gitignore` already excludes `key.properties`, `**/*.keystore`, and `**/*.jks`
- Existing tests must pass but no new exhaustive test suites are required

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["2.1"] },
    { "id": 2, "tasks": ["4.1", "4.2", "5.1", "5.2"] },
    { "id": 3, "tasks": ["5.3", "5.4"] },
    { "id": 4, "tasks": ["7.1", "7.2", "8.1"] },
    { "id": 5, "tasks": ["9.1", "9.2", "9.3"] },
    { "id": 6, "tasks": ["9.4"] },
    { "id": 7, "tasks": ["9.5", "9.6", "9.7"] },
    { "id": 8, "tasks": ["11.1", "12.1", "12.2", "12.3", "13.1"] },
    { "id": 9, "tasks": ["14.1", "18.1"] },
    { "id": 10, "tasks": ["14.2"] },
    { "id": 11, "tasks": ["14.3"] },
    { "id": 12, "tasks": ["16.1"] },
    { "id": 13, "tasks": ["19.1"] },
    { "id": 14, "tasks": ["21.1"] },
    { "id": 15, "tasks": ["22.1"] }
  ]
}
```
