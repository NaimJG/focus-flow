# Signing Setup — Keystore Generation & Backup Procedure

> **WARNING:** NEVER generate or store real passwords in any committed file. This document describes the PROCEDURE only. All credentials must be stored in a password manager and never appear in code, scripts, or version-controlled files.

---

## 1. Keystore Generation

Generate the upload keystore using `keytool` (included with the JDK):

```bash
keytool -genkeypair -v \
  -keystore upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload
```

**Parameters explained:**

| Parameter | Value | Reason |
|---|---|---|
| `-keyalg RSA` | RSA algorithm | Industry standard for code signing |
| `-keysize 2048` | 2048-bit key | Minimum recommended by Google Play |
| `-validity 10000` | ~27 years | Exceeds Google Play's 25-year minimum requirement |
| `-alias upload` | "upload" | Identifies this as the upload key (not the app signing key) |

When prompted, provide:
- A strong keystore password (store in password manager immediately)
- A strong key password (store in password manager immediately)
- Your name/organization details for the certificate

---

## 2. Local Setup

### Place the keystore

Store the generated `upload-keystore.jks` in one of these locations:

- **Inside the project (gitignored):** `android/keystores/upload-keystore.jks`
- **Outside the project:** e.g., `~/.android/keystores/upload-keystore.jks`

Both `**/*.jks` and `**/*.keystore` are already excluded by `android/.gitignore`.

### Create `key.properties`

Create the file `android/app/key.properties` with the actual credentials:

```properties
storeFile=../keystores/upload-keystore.jks
storePassword=<YOUR_STORE_PASSWORD>
keyAlias=upload
keyPassword=<YOUR_KEY_PASSWORD>
```

Replace `<YOUR_STORE_PASSWORD>` and `<YOUR_KEY_PASSWORD>` with the real passwords you chose during keystore generation.

**Reference:** See `android/app/key.properties.example` for the template structure.

**Important:** `key.properties` is gitignored and must NEVER be committed.

---

## 3. Secure Storage & Backup Procedure

The upload keystore must be backed up in at least **2 secure locations**:

### Primary backup — Encrypted cloud storage

- Create a password-protected archive (e.g., `.zip` with AES-256 encryption) containing:
  - `upload-keystore.jks`
- Store the archive in a private cloud drive (Google Drive, OneDrive, or similar)
- Use a different password than the keystore password itself
- Store the archive password in your password manager

### Secondary backup — Hardware backup

- Copy `upload-keystore.jks` to an encrypted USB drive or external storage
- Store the physical device in a secure location (safe, locked drawer)
- Label the device clearly (e.g., "Focus Flow Upload Key Backup")

### Storage rules

| Location | Allowed |
|---|---|
| Password-protected archive in private cloud drive | Yes |
| Encrypted USB drive / external storage | Yes |
| Git repository | **NEVER** |
| Email (sent or drafts) | **NEVER** |
| Unencrypted cloud storage | **NEVER** |
| Shared/team drives without encryption | **NEVER** |
| Screenshots or plain text notes | **NEVER** |

---

## 4. Password Manager Procedure

Store the following entries in your password manager:

| Entry | Value |
|---|---|
| Keystore store password | The password used to protect the `.jks` file |
| Key password | The password for the "upload" alias within the keystore |
| Key alias | `upload` |
| Keystore location | Path or description of where the keystore file is stored |
| Backup archive password | The password protecting the cloud backup archive |

**Guidelines:**
- Use unique, randomly generated passwords (16+ characters recommended)
- Never reuse passwords from other services
- Never store passwords in code, scripts, `.env` files, or any committed file
- Document the key alias ("upload") so it can be referenced when configuring CI/CD or new machines

---

## 5. Google Play App Signing Enrollment

### What happens on first upload

When you upload your first AAB to Google Play Console:

1. Google prompts you to enroll in **Google Play App Signing**
2. You accept and Google generates (or you provide) the **app signing key**
3. From this point forward:
   - **You** sign the AAB with the **upload key** (the one generated above)
   - **Google** re-signs the final APK with the **app signing key** before delivering to users

### Key facts

| Aspect | Detail |
|---|---|
| Enrollment | Irreversible — cannot be undone once accepted |
| Upload key compromise | Google can reset your upload key (you request via Play Console) |
| App signing key | Managed exclusively by Google; you never handle it directly |
| Recovery | If your upload key is lost, Google can issue a new one after identity verification |

### Recommended action

- **Always enroll** in Google Play App Signing on first upload
- This provides a safety net: if the upload keystore is lost or compromised, Google can reset it without affecting end users
- Without enrollment, losing the signing key means losing the ability to update the app forever

---

## Quick Reference Checklist

- [ ] Generate keystore with the `keytool` command above
- [ ] Store passwords in password manager immediately
- [ ] Place keystore in gitignored location
- [ ] Create `android/app/key.properties` with real credentials
- [ ] Verify build works: `flutter build apk --release`
- [ ] Create encrypted cloud backup of keystore
- [ ] Create hardware backup of keystore
- [ ] On first Play Console upload: enroll in Google Play App Signing
