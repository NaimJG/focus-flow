# Play Console Upload Workflow — Focus Flow 1.0.0

## Overview

This document provides a complete step-by-step guide for uploading Focus Flow 1.0.0 to the Google Play Console for the first time. It covers app creation, store listing setup, content declarations, app signing enrollment, release creation, closed testing, and production promotion.

> **ALL STEPS IN THIS DOCUMENT ARE MANUAL.** They must be performed by the developer in a web browser at [play.google.com/console](https://play.google.com/console). No automated tooling exists for these procedures.

---

## Prerequisites

Before starting, ensure you have:

- [ ] A Google Play Developer account (verified, $25 fee paid)
- [ ] The signed AAB file generated via `flutter build appbundle --release`
- [ ] AAB metadata verified (applicationId, versionName `1.0.0`, versionCode `1`, targetSdk ≥36)
- [ ] Privacy policy published at a publicly accessible URL (`[PRIVACY_POLICY_URL]`)
- [ ] Store listing text ready (see `docs/store-listing/es-AR.md` and `docs/store-listing/en-US.md`)
- [ ] Visual assets ready (see `docs/store-listing/assets-checklist.md`):
  - 512×512 app icon (PNG)
  - 1024×500 feature graphic (PNG/JPEG)
  - At least 2 phone screenshots (6 recommended)
- [ ] Developer support email confirmed (`[DEVELOPER_EMAIL]`)

---

## Step 1: Create App Entry

**Location:** Play Console → All apps → Create app

1. Click **"Create app"**
2. Fill in the app details:

   | Field | Value |
   |---|---|
   | App name | `Focus Flow` |
   | Default language | Spanish (Latin America) — `es-419` |
   | App or game | App |
   | Free or paid | Free |

3. Check all declarations:
   - [x] The app complies with Developer Program Policies
   - [x] I accept the Developer Distribution Agreement
   - [x] I acknowledge that this app may be subject to US export laws

4. Click **"Create app"**

> **Note:** The app name can be changed later, but the free/paid status CANNOT be changed after publication.

---

## Step 2: Set Up Store Listing

**Location:** Play Console → Grow → Store presence → Main store listing

### 2.1 App Details

| Field | Value | Source |
|---|---|---|
| App name | `Focus Flow` | — |
| Short description | Copy from `docs/store-listing/es-AR.md` (≤80 chars) | `Gestiona tareas y sesiones Pomodoro offline. Organizá tu trabajo con enfoque.` |
| Full description | Copy from `docs/store-listing/es-AR.md` | See full text in that file |

### 2.2 Graphics

Upload the following assets:

| Asset | Specification | Source |
|---|---|---|
| App icon | 512×512 PNG, 32-bit with alpha | Resize from `assets/branding/app_icon.png` |
| Feature graphic | 1024×500 PNG or JPEG | Design per `docs/store-listing/assets-checklist.md` |
| Phone screenshots | 2–8 images, portrait recommended | Capture from release build (see assets checklist) |

### 2.3 Localized Listings (Optional)

To add the English listing:

1. Go to **Manage translations** → **Add language** → English (United States) — `en-US`
2. Copy content from `docs/store-listing/en-US.md`
3. Upload English screenshots (if available)

### 2.4 Contact Details

| Field | Value |
|---|---|
| Email | `[DEVELOPER_EMAIL]` |
| Phone | (optional — leave blank if preferred) |
| Website | (optional — leave blank if not available) |

---

## Step 3: Complete Content Declarations

### 3.1 Privacy Policy

**Location:** Play Console → Policy → App content → Privacy policy

1. Enter the privacy policy URL: `[PRIVACY_POLICY_URL]`
2. The URL must be publicly accessible (Google will verify it)
3. Click **Save**

> **Source:** The privacy policy content is in `docs/privacy-policy.md`. It must be hosted at a public URL before submission.

### 3.2 Data Safety Form

**Location:** Play Console → Policy → App content → Data safety

Answer the questionnaire as follows:

| Question | Answer | Rationale |
|---|---|---|
| Does your app collect or share any user data? | **No** | Focus Flow is 100% offline, no network communication |
| Does your app collect any of the listed data types? | **No** (all categories) | No analytics, no crash reporting, no telemetry |
| Is data collected encrypted in transit? | N/A | No data leaves the device |
| Can users request data deletion? | N/A (no data collected) | All data is local; uninstalling removes everything |

**Final declaration summary:**
- Data collected: **None**
- Data shared: **None**
- Security practices: Data stored locally on device only

> **Reference:** See `docs/checklists/data-safety-audit.md` for the full dependency audit supporting these declarations.

### 3.3 Ads Declaration

**Location:** Play Console → Policy → App content → Ads

1. Select: **"No, my app does not contain ads"**
2. Click **Save**

### 3.4 App Access

**Location:** Play Console → Policy → App content → App access

1. Select: **"All functionality is available without special access"**
2. No login credentials, demo accounts, or special instructions are needed
3. Click **Save**

> Focus Flow has no user accounts, no login, no premium features, and no restricted content.

### 3.5 Content Rating

**Location:** Play Console → Policy → App content → Content rating

1. Click **"Start questionnaire"**
2. Select category: **Utility, Productivity, Communication, or other**
3. Answer all questions:

   | Question | Answer |
   |---|---|
   | Does this app contain violence? | No |
   | Does this app contain sexual content? | No |
   | Does this app allow user interaction? | No |
   | Does this app contain profanity? | No |
   | Does this app contain drug references? | No |
   | Does this app allow purchases? | No |
   | Does this app share user location? | No |
   | Does this app contain ads? | No |

4. Click **"Save"** then **"Submit"**
5. Review the assigned ratings (expected: PEGI 3 / Everyone)

### 3.6 Target Audience and Content

**Location:** Play Console → Policy → App content → Target audience and content

1. Select target age group: **13 and above** (or as confirmed by the developer)
   - Do NOT select ages under 13 unless Families Policy compliance is implemented
2. Confirm: "Is this app directed at children?" → **No**
3. Click **Save**

> **Important:** If the target audience includes children under 13, additional Families Policy compliance is required. This is NOT in scope for v1.0.

### 3.7 News App Declaration

**Location:** Play Console → Policy → App content → News apps

1. Confirm: **"This is not a news app"**
2. Click **Save**

### 3.8 Government Apps Declaration (if prompted)

1. Confirm: **"This is not a government app"**

### 3.9 Financial Features Declaration (if prompted)

1. Confirm: **"This app does not provide financial services"**

### 3.10 Health Apps Declaration (if prompted)

1. Confirm: **"This is not a health app"**

---

## Step 4: Enroll in Google Play App Signing

**Location:** Play Console → Release → Setup → App signing

Google Play App Signing is **mandatory** for new apps since August 2021. Enrollment happens automatically on first AAB upload, but understanding the process is important.

### How it works:

1. **Upload key** — The key you sign the AAB with locally (configured in `key.properties`). Used only for uploading to Play Console.
2. **App signing key** — Managed by Google. Used to sign the final APK delivered to users.

### Enrollment steps:

1. Navigate to **Release** → **Setup** → **App signing**
2. On first visit for a new app, you'll see the enrollment screen
3. Choose: **"Use Google-generated key"** (recommended for new apps)
   - Google generates and securely stores the app signing key
   - You keep only the upload key
4. Alternatively: **"Export and upload a key from Java Keystore"** (if you want to provide your own app signing key)
5. Click **"Accept"** / **"Continue"**

### Key security implications:

- **Enrollment is IRREVERSIBLE** — you cannot opt out after enrolling
- If your upload key is lost or compromised, Google can reset it (this is the main benefit)
- The app signing key is stored in Google's secure infrastructure
- You can download the app signing certificate for verification purposes

> **Reference:** Keystore generation and backup procedures are documented in `docs/checklists/signing-setup.md`

---

## Step 5: Create Release

### 5.1 Choose Release Track

**Location:** Play Console → Release → Testing/Production

For **new personal accounts**, you MUST start with closed testing (see Step 6). For established or organization accounts, you may go directly to production.

| Account Type | First Release Track |
|---|---|
| New personal account (< 1 year) | Closed testing (required) |
| Established personal account | Production (may be available directly) |
| Organization account | Production (typically available directly) |

### 5.2 Upload AAB

1. Navigate to the chosen track (e.g., **Testing** → **Closed testing** → **Manage track**)
2. Click **"Create new release"**
3. If this is the first upload, App Signing enrollment will be prompted (see Step 4)
4. Under **"App bundles"**, click **"Upload"**
5. Select the AAB file: `build/app/outputs/bundle/release/app-release.aab`
6. Wait for upload and processing to complete
7. Verify the processed details:

   | Field | Expected Value |
   |---|---|
   | Version code | `1` |
   | Version name | `1.0.0` |
   | Min SDK | `21` (Flutter default) |
   | Target SDK | `36` |
   | Package name | `[APPLICATION_ID]` |

### 5.3 Release Notes

1. In the **"Release notes"** section, click **"Add language"** if needed
2. Add Spanish (Latin America) release notes — copy from `docs/release-notes/1.0.0.md`
3. Optionally add English release notes

### 5.4 Review and Roll Out

1. Click **"Review release"**
2. Verify there are no errors or warnings
3. Click **"Start rollout"** (for testing) or **"Start rollout to production"**
4. Confirm the rollout

---

## Step 6: Closed Testing Track Setup

> **This step is required for new personal Play Console accounts.** Google requires at least 12 testers and 14 consecutive days of testing before granting production access.

### 6.1 Create Closed Testing Track

**Location:** Play Console → Release → Testing → Closed testing

1. Click **"Create track"** (or use the default closed testing track)
2. Track name: `Internal testers` (or any descriptive name)

### 6.2 Manage Testers

1. Go to the **"Testers"** tab of your closed testing track
2. Click **"Create email list"**
3. Name the list: `Focus Flow Beta Testers`
4. Add at least **12 email addresses** (Google accounts required)
   - These can be friends, family, colleagues, or developer community members
   - Each tester must have a Google account
   - Testers must actively opt in (see 6.3)
5. Click **Save changes**

> **Requirement:** A minimum of **12 unique testers** must opt in to the testing program. Simply adding emails is not sufficient — testers must actually join via the opt-in link.

### 6.3 Distribute Opt-In Link

1. After creating the release, go to the **"Testers"** tab
2. Copy the **opt-in URL** (format: `https://play.google.com/apps/testing/[APPLICATION_ID]`)
3. Send this link to all testers with instructions:
   - Open the link in a browser while signed into their Google account
   - Click **"Become a tester"** / **"Accept invite"**
   - After opting in, they can install the app from Play Store (may take a few hours to appear)
4. Track how many testers have opted in (visible in the Play Console)

### 6.4 14-Day Requirement

- The 14-day countdown begins when:
  - The closed testing release is live AND
  - At least 12 testers have opted in
- Monitor the countdown in Play Console under **Release** → **Production** (it shows when production access will be available)
- During this period:
  - Testers can install and use the app
  - You can publish updates to the closed testing track
  - Monitor crash reports and feedback from testers
  - Fix any issues discovered during testing

### 6.5 What Testers See

- Testers find the app in the Play Store after opting in (may take up to 24 hours)
- The listing shows "(Early access)" or similar label
- Testers can leave private feedback (not public reviews)
- Testers can opt out at any time

---

## Step 7: Transition from Closed Testing to Production

> **Only proceed after the 14-day closed testing period is complete** (if applicable).

### 7.1 Verify Production Access

1. Navigate to **Release** → **Production**
2. If access is granted, you'll see the option to **"Create new release"**
3. If still locked, the Console will show the remaining days or requirements

### 7.2 Promote Release to Production

**Option A: Promote existing release**

1. Go to **Release** → **Testing** → **Closed testing**
2. Find the tested release
3. Click **"Promote release"** → **"Production"**
4. Review the release details (version code, AAB, release notes)
5. Click **"Review release"** then **"Start rollout to Production"**
6. Choose rollout percentage: **100%** (for first release)
7. Confirm

**Option B: Create new production release**

1. Go to **Release** → **Production** → **"Create new release"**
2. Upload the same (or updated) AAB
3. Add release notes
4. Review and roll out at 100%

### 7.3 Production Pre-Launch Checks

Before promoting to production, verify:

- [ ] All content declarations are complete (privacy policy, data safety, content rating, target audience, ads, app access)
- [ ] Store listing is complete (all required fields, graphics uploaded)
- [ ] No policy warnings or errors in the Play Console dashboard
- [ ] Release notes are filled in for the target languages

---

## Step 8: Monitor Review Process

### 8.1 Expected Review Timelines

| Scenario | Typical Timeline |
|---|---|
| New app, first submission | 3–7 business days (can take longer) |
| App update (after initial approval) | 1–3 business days |
| Expedited review (if requested) | 1–2 business days (not guaranteed) |
| Holiday periods / policy changes | May be significantly longer |

> **Note:** Review times vary significantly. Google does not guarantee specific timelines. First submissions from new accounts typically take longer.

### 8.2 Review Status Indicators

| Status | Meaning |
|---|---|
| Draft | Release created but not submitted |
| In review | Google is reviewing the app |
| Approved / Live | App is published and available on Play Store |
| Rejected | Policy violation found (see 8.3) |
| Suspended | Serious policy violation — requires appeal |

### 8.3 Common Rejection Reasons for Productivity Apps

| Reason | Likely Cause | Prevention |
|---|---|---|
| **Metadata policy violation** | Misleading description, keyword stuffing, or claims about features that don't exist | Ensure store listing only describes implemented features |
| **Privacy policy issues** | URL not accessible, content doesn't match app behavior, or missing from the app | Verify URL is live and content matches Data Safety declarations |
| **Data Safety mismatch** | Declared "no data collected" but app requests INTERNET permission | Verify the merged release manifest has no INTERNET permission |
| **Broken functionality** | Crash on startup, critical feature doesn't work | Complete the verification checklist (`docs/checklists/verification-checklist.md`) |
| **Impersonation** | App name or icon too similar to an existing app | Verify "Focus Flow" doesn't conflict with established apps |
| **Minimum functionality** | App deemed to not provide sufficient value | Ensure all three modules (Todo, Pomodoro, Statistics) are fully functional |
| **Content rating mismatch** | Content doesn't match the declared rating | Ensure the questionnaire answers match actual app content |
| **Target audience issues** | App marked for children but doesn't comply with Families Policy | Keep target audience at 13+ unless Families Policy is implemented |

### 8.4 If Rejected

1. Read the rejection email carefully — Google specifies the exact policy violation
2. Fix the identified issue (code change, metadata update, or declaration correction)
3. Navigate to the rejected release in Play Console
4. Make necessary changes
5. Resubmit for review
6. Typical re-review time: 1–3 business days

### 8.5 Post-Approval Actions

Once the app is live on Google Play:

1. Verify the Play Store listing appears correctly (search for "Focus Flow")
2. Install the app from Play Store on a test device to confirm it works
3. Create Git tag: `git tag v1.0.0` on the exact commit used for the uploaded AAB
4. Push the tag: `git push origin v1.0.0`
5. Merge `chore/release-preparation` into `main` via pull request
6. Monitor the Play Console for:
   - Crash reports (Android Vitals)
   - User reviews and ratings
   - Pre-launch report results (automated testing by Google)

---

## Quick Reference: Declaration Summary

| Declaration | Focus Flow Answer |
|---|---|
| Privacy policy URL | `[PRIVACY_POLICY_URL]` |
| Data collected | None |
| Data shared | None |
| Contains ads | No |
| App access | All functionality available without special access |
| Content rating | Utility/Productivity — expected: Everyone / PEGI 3 |
| Target audience | 13+ (do NOT select under-13) |
| News app | No |
| Government app | No |
| Financial app | No |
| Health app | No |

---

## File References

| Document | Purpose |
|---|---|
| `docs/store-listing/es-AR.md` | Spanish store listing text (primary) |
| `docs/store-listing/en-US.md` | English store listing text (secondary) |
| `docs/store-listing/assets-checklist.md` | Visual asset specifications and status |
| `docs/release-notes/1.0.0.md` | Release notes for v1.0.0 |
| `docs/privacy-policy.md` | Privacy policy content (Spanish + English) |
| `docs/checklists/data-safety-audit.md` | Dependency data audit supporting Data Safety form |
| `docs/checklists/signing-setup.md` | Keystore generation and backup procedures |
| `docs/checklists/verification-checklist.md` | Manual QA checklist (complete before upload) |
| `docs/checklists/automated-checks.md` | Pre-build automated verification commands |

---

## Placeholders to Resolve Before Upload

| Placeholder | Where Used | Status |
|---|---|---|
| `[APPLICATION_ID]` | AAB package name, Play Console app entry | Must be confirmed before upload |
| `[DEVELOPER_EMAIL]` | Store listing contact, privacy policy | Must be confirmed before upload |
| `[PRIVACY_POLICY_URL]` | Play Console declaration, in-app settings, privacy policy footer | Must be a live public URL before upload |
