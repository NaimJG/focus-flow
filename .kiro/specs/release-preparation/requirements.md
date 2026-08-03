# Requirements Document — Release Preparation (Focus Flow 1.0.0)

## Introduction

This specification covers the complete preparation of Focus Flow 1.0.0 for its first Google Play Store release. It is a documentation and configuration spec — no new product features are implemented. The scope includes: finalizing application identity, configuring release signing, preparing store listing materials, creating a privacy policy, verifying release quality, and documenting the Play Console upload workflow.

All work takes place on branch `chore/release-preparation`.

## Glossary

- **Application_Identity**: The combination of applicationId, namespace, app label, and launcher icon that permanently identifies the app on Google Play.
- **ApplicationId**: The unique identifier registered with Google Play (e.g., `com.ncambe.focusflow`). It is permanent after first publication.
- **Namespace**: The Android R class package declared in `build.gradle.kts`. Must be a valid Java package name.
- **Upload_Key**: The private key used to sign the Android App Bundle before uploading to Google Play.
- **App_Signing_Key**: The key Google Play uses to sign the final APK delivered to users (managed by Google Play App Signing).
- **AAB**: Android App Bundle — the publishing format required by Google Play.
- **APK**: Android Package — the installable format used for local device verification.
- **Play_Console**: The Google Play developer portal used to manage app listings, releases, and compliance declarations.
- **Data_Safety_Form**: The Play Console questionnaire declaring what user data the app collects, shares, and how it is secured.
- **Closed_Testing_Track**: A Google Play release track limited to invited testers, required for new personal accounts before production access.
- **Store_Listing**: The public-facing app page on Google Play including name, description, screenshots, and metadata.
- **Release_Build_System**: The combination of Flutter CLI, Gradle, and signing configuration that produces a release-signed AAB.
- **Privacy_Policy**: A legal document describing data collection, usage, and user rights. Required by Google Play.
- **Checkpoint**: A point in the workflow where explicit user confirmation is required before proceeding.
- **Verification_Checklist**: A manual or automated procedure to confirm the release build meets quality standards.

## Unresolved Decisions

The following values require explicit user confirmation before implementation. They are referenced throughout this document but are NOT finalized:

| Decision | Candidates / Notes |
|---|---|
| Final Android applicationId | Candidates: `com.ncambe.focusflow`, `com.naimcambe.focusflow` — permanent after publication |
| Final namespace | Must match or be compatible with the chosen applicationId |
| Developer support email | Required for Play Console and store listing |
| Public privacy-policy URL | Required for Play Console; must be publicly accessible |
| Play Console account type | Personal or Organization; affects closed-testing requirements |
| Target-audience age ranges | Affects content rating and compliance declarations |
| Production release date | Determines deadline for closed-testing completion |

---

## Requirements

### Requirement 1: Application Identity Confirmation

**User Story:** As a developer, I want to finalize the application identity configuration, so that the app is permanently registered with the correct identity on Google Play.

#### Acceptance Criteria

1. THE Release_Build_System SHALL use the user-confirmed applicationId in `android/app/build.gradle.kts`.
2. THE Release_Build_System SHALL use a namespace consistent with the confirmed applicationId in `android/app/build.gradle.kts`.
3. WHEN the applicationId is confirmed, THE Release_Build_System SHALL relocate `MainActivity.kt` to a directory path matching the confirmed applicationId package structure.
4. THE Release_Build_System SHALL declare `android:label="Focus Flow"` in the main `AndroidManifest.xml`.
5. IF the applicationId has not been explicitly confirmed by the user, THEN THE Release_Build_System SHALL NOT modify the current applicationId value.
6. THE Release_Build_System SHALL document the discrepancy between the current file path (`com/example/focus_flow/`) and the package declaration (`com.ncambe.focus_flow`) as a known issue to resolve during identity confirmation.

**Checkpoint:** The applicationId is permanent after first Play Store upload. Explicit user confirmation is required before any modification.

---

### Requirement 2: Version Configuration

**User Story:** As a developer, I want to verify the version is correctly configured for the first release, so that Google Play registers the correct version information.

#### Acceptance Criteria

1. THE Release_Build_System SHALL read version `1.0.0+1` from `pubspec.yaml` where `1.0.0` maps to `versionName` and `1` maps to `versionCode`.
2. THE Release_Build_System SHALL use `flutter.versionCode` and `flutter.versionName` in `build.gradle.kts` rather than hardcoded values.
3. WHEN the release AAB is built, THE Release_Build_System SHALL produce a bundle with versionName `1.0.0` and versionCode `1`.

---

### Requirement 3: Android SDK Target Compliance

**User Story:** As a developer, I want the app to target API 36 or higher, so that it meets the Google Play requirement effective August 31, 2026.

#### Acceptance Criteria

1. THE Release_Build_System SHALL target API level 36 or higher (resolved via `flutter.targetSdkVersion`).
2. THE Release_Build_System SHALL compile against SDK level 36 or higher (resolved via `flutter.compileSdkVersion`).
3. WHEN Flutter-managed SDK values already resolve to API 36 or higher, THE Release_Build_System SHALL use `flutter.targetSdkVersion` and `flutter.compileSdkVersion` without hardcoding values.
4. IF Flutter-managed SDK values resolve to less than API 36, THEN THE Release_Build_System SHALL override with explicit values of at least 36.
5. THE Release_Build_System SHALL maintain `flutter.minSdkVersion` as the minimum SDK value.

---

### Requirement 4: Release Signing Configuration

**User Story:** As a developer, I want to configure secure release signing, so that the AAB is properly signed for Google Play upload.

#### Acceptance Criteria

1. WHEN building a release, THE Release_Build_System SHALL sign the output with a dedicated upload key (not the debug key).
2. THE Release_Build_System SHALL store the upload keystore file outside the Git repository.
3. THE Release_Build_System SHALL load signing credentials from a `key.properties` file located in `android/` and excluded from version control.
4. THE Release_Build_System SHALL define a `signingConfigs.release` block in `build.gradle.kts` that reads `storeFile`, `storePassword`, `keyAlias`, and `keyPassword` from `key.properties`.
5. THE Release_Build_System SHALL reference `signingConfigs.release` in the `buildTypes.release` block.
6. THE Release_Build_System SHALL generate the upload keystore using `keytool` with a minimum validity of 25 years and RSA key size of at least 2048 bits.
7. THE Release_Build_System SHALL NOT store keystore files, passwords, or key.properties in the Git repository.
8. IF `key.properties` is missing at build time, THEN THE Release_Build_System SHALL fail with a clear error message rather than falling back to debug signing.
9. THE Release_Build_System SHALL document a secure backup procedure for the upload keystore and its credentials.
10. WHEN uploading to Play Console for the first time, THE Release_Build_System SHALL enroll in Google Play App Signing.

---

### Requirement 5: Release Build Verification

**User Story:** As a developer, I want to verify the release build contains no debug artifacts, so that the published app behaves as intended for end users.

#### Acceptance Criteria

1. THE Release_Build_System SHALL produce a release APK that is not debuggable (`android:debuggable` is absent or false).
2. THE Release_Build_System SHALL NOT include debug-only permissions (INTERNET) in the merged release manifest.
3. THE Release_Build_System SHALL include the configured launcher icon and splash screen in the release build.
4. THE Release_Build_System SHALL include all generated localization files (Spanish and English) in the release build.
5. THE Release_Build_System SHALL include current Isar generated code (`build_runner` output) in the release build.
6. THE Release_Build_System SHALL enable tree shaking and code obfuscation for the release build type.
7. THE Release_Build_System SHALL NOT include mock data, debug screens, or debug-only dependencies in the release build.
8. WHEN the release APK is installed on a physical device, THE Application_Identity SHALL display the correct app name, launcher icon, and splash screen.

---

### Requirement 6: Permissions and Manifest Audit

**User Story:** As a developer, I want to audit all permissions in the final release manifest, so that the app requests only necessary permissions and the Data Safety form is accurate.

#### Acceptance Criteria

1. THE Release_Build_System SHALL NOT declare INTERNET permission in the release manifest (the app is offline-first with no network features).
2. THE Release_Build_System SHALL NOT declare POST_NOTIFICATIONS permission (no notification functionality exists).
3. WHEN building a release, THE Release_Build_System SHALL merge only `src/main/AndroidManifest.xml` (without debug or profile manifests).
4. THE Verification_Checklist SHALL document all permissions contributed by dependencies (isar, isar_flutter_libs, path_provider, provider, intl, cupertino_icons, url_launcher).
5. IF a dependency contributes an unexpected permission, THEN THE Release_Build_System SHALL remove it via a manifest merge rule (`tools:node="remove"`).

---

### Requirement 7: Privacy Policy Creation

**User Story:** As a developer, I want to create an accurate privacy policy, so that the app complies with Google Play requirements and informs users about data practices.

#### Acceptance Criteria

1. THE Privacy_Policy SHALL be created at `docs/privacy-policy.md` in both Spanish (primary) and English.
2. THE Privacy_Policy SHALL accurately state that the app operates entirely offline with no network communication.
3. THE Privacy_Policy SHALL accurately state that no user accounts, authentication, or registration exist.
4. THE Privacy_Policy SHALL accurately state that no analytics, crash reporting, or telemetry data is collected.
5. THE Privacy_Policy SHALL accurately state that no advertisements are displayed.
6. THE Privacy_Policy SHALL accurately state that no user data is shared with third parties.
7. THE Privacy_Policy SHALL accurately state that all user data is stored exclusively on the local device.
8. THE Privacy_Policy SHALL include a placeholder for the developer contact email (unresolved decision).
9. THE Privacy_Policy SHALL include the date of last update.
10. IF the developer email is not yet confirmed, THEN THE Privacy_Policy SHALL use a clearly marked placeholder (`[DEVELOPER_EMAIL]`).

---

### Requirement 8: In-App Privacy Policy Access

**User Story:** As a user, I want to access the privacy policy from within the app settings, so that I can review data practices without leaving the app.

#### Acceptance Criteria

1. WHEN the settings screen is displayed, THE Settings_Screen SHALL show a "Privacy Policy" option after the existing settings sections.
2. WHEN the user taps the Privacy Policy option, THE Settings_Screen SHALL open the privacy policy URL in an external browser using `url_launcher`.
3. THE Release_Build_System SHALL add `url_launcher` as a dependency in `pubspec.yaml`.
4. THE Application_Identity SHALL declare the privacy policy URL in a single centralized location (not duplicated across files).
5. IF the privacy policy URL is not yet confirmed, THEN THE Settings_Screen SHALL use a clearly marked placeholder URL that is replaced before release.
6. THE Settings_Screen SHALL NOT introduce a new settings controller for the privacy policy functionality.
7. IF `url_launcher` fails to open the URL, THEN THE Settings_Screen SHALL display a snackbar with a user-friendly error message.

---

### Requirement 9: Data Safety Assessment

**User Story:** As a developer, I want to audit all dependencies for data collection behavior, so that the Data Safety form on Play Console is filled accurately.

#### Acceptance Criteria

1. THE Verification_Checklist SHALL document the data collection behavior of each dependency: flutter SDK, provider, isar, isar_flutter_libs, path_provider, intl, flutter_localizations, cupertino_icons, url_launcher.
2. THE Verification_Checklist SHALL confirm that no dependency transmits data off-device.
3. THE Data_Safety_Form SHALL declare "No data collected" and "No data shared" based on the audit results.
4. IF a dependency is found to collect or transmit data, THEN THE Verification_Checklist SHALL document the specific data type and transmission behavior.
5. THE Verification_Checklist SHALL document that `url_launcher` opens external URLs but does not itself collect or transmit app data.

---

### Requirement 10: Google Play Content Declarations

**User Story:** As a developer, I want to document all required Play Console content declarations, so that the app passes review without delays.

#### Acceptance Criteria

1. THE Play_Console SHALL receive a privacy policy URL declaration.
2. THE Play_Console SHALL receive a completed Data Safety form declaring no data collection and no data sharing.
3. THE Play_Console SHALL receive an Ads declaration stating the app does not contain ads.
4. THE Play_Console SHALL receive an App Access declaration stating the app requires no login or special access.
5. THE Play_Console SHALL receive a completed Content Rating questionnaire.
6. THE Play_Console SHALL receive a Target Audience declaration with user-confirmed age ranges (unresolved decision).
7. THE Play_Console SHALL receive declarations confirming the app is not: a news app, government app, financial app, or health app.
8. IF the target audience includes children under 13, THEN THE Play_Console SHALL require additional Families Policy compliance (not in v1.0 scope).

---

### Requirement 11: Closed Testing Track Requirement

**User Story:** As a developer, I want to understand and execute the closed testing requirement, so that the app qualifies for production release on a new personal Play Console account.

#### Acceptance Criteria

1. WHEN the Play Console account is a new personal account, THE Play_Console SHALL require a closed testing track with at least 12 testers.
2. WHEN the Play Console account is a new personal account, THE Play_Console SHALL require the closed testing track to run for at least 14 consecutive days before production access is granted.
3. THE Verification_Checklist SHALL document the closed testing setup procedure including: creating the track, adding testers via email list, distributing the opt-in link, and monitoring the 14-day countdown.
4. IF the Play Console account is an organization account or an established personal account, THEN the closed testing requirement may not apply (user must confirm account status).

---

### Requirement 12: Store Listing Metadata

**User Story:** As a developer, I want to prepare all store listing text and metadata, so that the app page on Google Play is complete and professional.

#### Acceptance Criteria

1. THE Store_Listing SHALL define the app name as "Focus Flow".
2. THE Store_Listing SHALL include a short description of 80 characters or fewer in Spanish (primary) and English (optional).
3. THE Store_Listing SHALL include a full description in Spanish (primary) and English (optional).
4. THE Store_Listing SHALL specify the category as "Productivity".
5. THE Store_Listing SHALL include the developer support email (unresolved decision — use placeholder).
6. THE Store_Listing SHALL include the privacy policy URL (unresolved decision — use placeholder).
7. THE Store_Listing SHALL include release notes for version 1.0.0.
8. THE Store_Listing SHALL be drafted in repository files: `docs/store-listing/es-AR.md`, `docs/store-listing/en-US.md`, and `docs/release-notes/1.0.0.md`.
9. THE Store_Listing SHALL NOT contain false claims about features that do not exist (e.g., notifications, cloud sync, social features).

---

### Requirement 13: Store Visual Assets

**User Story:** As a developer, I want to prepare all required visual assets for the Play Store listing, so that the app page meets Google Play's graphic requirements.

#### Acceptance Criteria

1. THE Store_Listing SHALL include a 512×512 pixel app icon in PNG format.
2. THE Store_Listing SHALL include a 1024×500 pixel feature graphic in PNG format.
3. THE Store_Listing SHALL include phone screenshots covering: Todo list, Task form, Pomodoro running, General statistics, Per-task statistics, and Settings.
4. THE Store_Listing SHALL provide screenshots in Spanish as the primary language, with English as optional.
5. THE Store_Listing screenshots SHALL NOT display the debug banner.
6. THE Store_Listing screenshots SHALL show realistic but non-personal data (no real names, emails, or identifiable information).
7. THE Store_Listing screenshots SHALL be captured from a release-like build state.

---

### Requirement 14: Release Quality Verification (Manual)

**User Story:** As a developer, I want a manual verification checklist for the release build, so that critical functionality is confirmed working before submission.

#### Acceptance Criteria

1. THE Verification_Checklist SHALL verify app startup displays correct identity (name, icon, splash).
2. THE Verification_Checklist SHALL verify language switching between Spanish and English works correctly.
3. THE Verification_Checklist SHALL verify Todo CRUD operations (create, read, update, delete).
4. THE Verification_Checklist SHALL verify Pomodoro timer flow (start, pause, complete work session, break session).
5. THE Verification_Checklist SHALL verify Statistics display accuracy after completing Pomodoro sessions.
6. THE Verification_Checklist SHALL verify Settings persistence across app restarts.
7. THE Verification_Checklist SHALL verify the privacy policy link opens in an external browser.
8. THE Verification_Checklist SHALL verify the app operates fully without network connectivity.
9. THE Verification_Checklist SHALL verify data survival after process termination and restart.
10. THE Verification_Checklist SHALL verify layout integrity at 360dp width (small phone).
11. THE Verification_Checklist SHALL verify text readability at 200% system text scaling.
12. THE Verification_Checklist SHALL verify correct appearance in both light and dark themes.
13. THE Verification_Checklist SHALL verify the app on at least one physical device and one emulator.

---

### Requirement 15: Automated Verification

**User Story:** As a developer, I want to run automated checks before building the release, so that code quality and consistency are confirmed.

#### Acceptance Criteria

1. THE Verification_Checklist SHALL run `dart format .` and confirm no formatting changes are needed.
2. THE Verification_Checklist SHALL run `flutter gen-l10n` and confirm localization files are current.
3. THE Verification_Checklist SHALL run `dart run build_runner build --delete-conflicting-outputs` and confirm generated code is current.
4. THE Verification_Checklist SHALL run `flutter analyze` and confirm zero analysis issues.
5. THE Verification_Checklist SHALL run `flutter test` and confirm all existing tests pass.
6. IF any automated check fails, THEN THE Release_Build_System SHALL resolve the issue before proceeding to build.

---

### Requirement 16: Release APK Verification

**User Story:** As a developer, I want to build and install a release APK on a physical device, so that I can verify the signed release behaves correctly before generating the final AAB.

#### Acceptance Criteria

1. THE Release_Build_System SHALL produce a release APK via `flutter build apk --release`.
2. WHEN the release APK is installed on a physical device, THE Application_Identity SHALL display the correct app name and launcher icon.
3. WHEN the release APK is installed on a physical device, THE Application_Identity SHALL display the configured splash screen on startup.
4. WHEN the release APK is running, THE Application_Identity SHALL persist data correctly across app restarts.
5. WHEN the release APK is running, THE Application_Identity SHALL NOT exhibit debug behavior (debug banner, debug logging to logcat, debug assertions).
6. THE Release_Build_System SHALL verify the APK is signed with the upload key (not the debug key) using `apksigner verify`.

**Checkpoint:** The signed APK must be installed and manually verified on a physical device before proceeding to AAB generation.

---

### Requirement 17: Android App Bundle Generation

**User Story:** As a developer, I want to generate a release-signed AAB, so that I can upload it to Google Play.

#### Acceptance Criteria

1. THE Release_Build_System SHALL produce a release AAB via `flutter build appbundle --release`.
2. THE Release_Build_System SHALL sign the AAB with the upload key configured in `signingConfigs.release`.
3. THE Release_Build_System SHALL produce an AAB with the confirmed applicationId.
4. THE Release_Build_System SHALL produce an AAB with versionName `1.0.0` and versionCode `1`.
5. THE Release_Build_System SHALL produce an AAB targeting API level 36 or higher.
6. THE Release_Build_System SHALL NOT include secrets, keystore files, or key.properties content in the AAB.
7. THE Release_Build_System SHALL verify the AAB file size is reasonable (documented expected range based on app complexity).

**Checkpoint:** The AAB must be successfully generated and its metadata verified before proceeding to Play Console upload.

---

### Requirement 18: Play Console Upload Workflow

**User Story:** As a developer, I want a documented step-by-step Play Console upload process, so that the first submission is completed without errors.

#### Acceptance Criteria

1. THE Verification_Checklist SHALL document the complete Play Console upload workflow from app creation to production submission.
2. THE Verification_Checklist SHALL include steps for: creating the app entry, setting up the store listing, uploading the AAB, completing content declarations, creating a release, and submitting for review.
3. THE Verification_Checklist SHALL document the enrollment process for Google Play App Signing.
4. THE Verification_Checklist SHALL document the closed testing track setup (if applicable per account type).
5. WHEN the account requires closed testing, THE Verification_Checklist SHALL document the transition from closed testing to production release request.
6. THE Verification_Checklist SHALL document expected review timelines and potential rejection reasons to monitor.

---

### Requirement 19: Git and Release Workflow

**User Story:** As a developer, I want a documented git workflow for the release, so that the release branch, commits, and tag are managed consistently.

#### Acceptance Criteria

1. THE Release_Build_System SHALL perform all release preparation work on branch `chore/release-preparation`.
2. THE Release_Build_System SHALL organize commits into logical groups: identity configuration, signing setup, privacy policy, store listing, build verification.
3. WHEN the AAB has been uploaded and confirmed working on Play Console, THE Release_Build_System SHALL create a Git tag `v1.0.0` on the exact commit used to produce the uploaded AAB.
4. THE Release_Build_System SHALL NOT create the `v1.0.0` tag before the AAB is confirmed uploaded.
5. THE Release_Build_System SHALL merge `chore/release-preparation` into `main` via pull request after production submission.
6. THE Release_Build_System SHALL use Conventional Commits format for all commits (e.g., `chore(release): configure upload signing`).

---

### Requirement 20: Notification and Sound Behavior Audit

**User Story:** As a developer, I want to accurately document the current sound and notification state, so that the release does not claim capabilities that do not exist.

#### Acceptance Criteria

1. THE Verification_Checklist SHALL document that the `soundEnabled` setting exists in the domain model but no audio playback mechanism is implemented.
2. THE Verification_Checklist SHALL confirm that no audio packages (just_audio, audioplayers, etc.) are present in `pubspec.yaml`.
3. THE Verification_Checklist SHALL confirm that no notification packages or foreground services are implemented.
4. THE Store_Listing SHALL NOT claim notification or sound functionality unless it is actually implemented before release.
5. THE Data_Safety_Form SHALL NOT declare audio or notification-related permissions.

---

### Requirement 21: Out-of-Scope Exclusions

**User Story:** As a developer, I want explicit documentation of what is out of scope, so that scope creep does not delay the release.

#### Acceptance Criteria

1. THE Release_Build_System SHALL NOT include iOS, web, or Windows platform preparation.
2. THE Release_Build_System SHALL NOT include Firebase, analytics, Crashlytics, or any telemetry service.
3. THE Release_Build_System SHALL NOT include AdMob, advertisements, in-app purchases, or subscriptions.
4. THE Release_Build_System SHALL NOT include user accounts, cloud sync, or backend services.
5. THE Release_Build_System SHALL NOT include push notifications, social login, or CI/CD store deployment.
6. THE Release_Build_System SHALL NOT include multiple build flavors, product name changes, icon redesigns, or splash redesigns.
7. THE Release_Build_System SHALL NOT implement new product features as part of release preparation.

---

## Category Classification

For clarity, each requirement maps to one of five implementation categories:

| Category | Requirements |
|---|---|
| Repository changes (code/config) | 1, 2, 3, 4, 5, 6, 8, 15, 16, 17, 19 |
| Secrets outside Git | 4 (keystore, key.properties) |
| Manual Play Console work | 10, 11, 18 |
| Store-listing assets and text | 7, 12, 13 |
| Testing and verification | 5, 6, 9, 14, 15, 16, 20 |

---

## Testing Scope

### Essential (must pass before release)
- All existing unit and widget tests (`flutter test`)
- Static analysis (`flutter analyze`)
- Formatting compliance (`dart format .`)
- Manual verification checklist (Requirement 14)
- Release APK installation test (Requirement 16)

### Optional (recommended but not blocking)
- Extended accessibility testing with TalkBack
- Performance profiling on low-end devices
- Extended locale testing beyond es/en

No new exhaustive test suites are required for release preparation. Existing tests must continue to pass.
