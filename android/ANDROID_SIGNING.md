# Android App Bundle signing (Play Console "wrong key" error)

## What to do now

1. **Find the keystore** that was used for the **first** FiksOpp Provider upload to Play. Its SHA1 must be:  
   `6C:4E:7E:7B:EA:5B:AA:BB:6F:08:95:10:A6:C1:57:41:1C:81:F2:20`  
   Check any `.jks` / `.keystore` files with:  
   `keytool -list -v -keystore /path/to/keystore.jks`
2. **Create `android/key.properties`** (see format in `key.properties.example`) pointing to that keystore, with correct `storePassword`, `keyPassword`, `keyAlias`, and `storeFile`.
3. **Build and upload:**  
   `flutter clean && flutter build appbundle`  
   Upload the new `build/app/outputs/bundle/release/app-release.aab`.

If you no longer have that keystore, you must request an **upload key reset** in Play Console (Setup → App signing → Request upload key reset) and then use the new key. See the rest of this file and `HOW_TO_RESET_UPLOAD_KEY.md` for details.

---

## Why you see this error

Play Console expects your app bundle to be signed with a **specific certificate** (upload key):

- **Expected SHA1 (FiksOpp Provider):** `6C:4E:7E:7B:EA:5B:AA:BB:6F:08:95:10:A6:C1:57:41:1C:81:F2:20`
- **Wrong SHA1 (e.g. debug or other key):** `D2:62:F2:83:...` or `B3:DB:69:75:...` — upload will be rejected.

In this project, **release builds use the release keystore only if `key.properties` exists**. If `key.properties` is missing, the build uses the **debug** keystore, which has the second SHA1. So the bundle you uploaded was signed with the debug key instead of the key Play has on file.

---

## Fix: sign with the correct key

### 1. Locate the keystore that matches the expected SHA1

You need the **keystore file** (`.jks` or `.keystore`) that was used when the app was first uploaded to Play. Its SHA1 must be:

**Expected (from Play Console):** `6C:4E:7E:7B:EA:5B:AA:BB:6F:08:95:10:A6:C1:57:41:1C:81:F2:20`

**Keystores found on your Mac** (check each with the command below to see its SHA1):

| Path | Notes |
|------|--------|
| `/Users/mac/.android/debug.keystore` | **Debug key** — SHA1 is `B3:DB:69:75:...` (this is what was uploaded by mistake; do **not** use for release). |
| `/Users/mac/my-release-key.jks` | SHA1 `B5:8C:94:06:0F:77:...` — **does not match** expected. Alias: `upload`. |
| `/Users/mac/ImagifyAI/android/upload-keystore.jks` | Another project’s upload key. Run keytool to see if SHA1 is `30:C8:A9:...`. |

**Check SHA1 of any keystore** (you will be prompted for the keystore password):

```bash
keytool -list -v -keystore /path/to/your.keystore.jks
```

To check FiksOpp keystores only (you’ll be asked for password for each):

```bash
keytool -list -v -keystore /Users/mac/fiksOpp---User/android/app/keystore_new.jks
```

In the output, find **SHA1:**. If it is `6C:4E:7E:7B:EA:5B:AA:BB:6F:08:95:10:A6:C1:57:41:1C:81:F2:20`, use that keystore in `key.properties`. Note the **Alias name** from the output; you’ll need it for `keyAlias`.

**Optional:** From the project root you can run `bash android/list_keystore_sha1.sh` to list SHA1 for the keystores above (you’ll be prompted for passwords for non-debug keys).

### 2. Create `key.properties` in the `android/` folder

In the project, create **`android/key.properties`** (this file is git-ignored; do not commit it):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=YOUR_KEY_ALIAS
storeFile=path/to/your/keystore.jks
```

- **storeFile:** Path to the keystore file. Use either:
  - An **absolute path**, e.g. `C:/Users/You/keys/upload-keystore.jks` or `/Users/you/keys/upload-keystore.jks`
  - Or a **relative path from `android/app/`**, e.g. `../upload-keystore.jks` if you put the keystore in `android/`.
- **keyAlias:** The alias of the key inside the keystore (e.g. `upload` or `key0`).
- **storePassword** / **keyPassword:** The passwords for the keystore and the key.

Example if the keystore is at `android/upload-keystore.jks`:

```properties
storePassword=mySecretStorePass
keyPassword=mySecretKeyPass
keyAlias=upload
storeFile=../upload-keystore.jks
```

### 3. Build the app bundle again

From the project root:

```bash
flutter clean
flutter build appbundle
```

The output AAB will be at `build/app/outputs/bundle/release/app-release.aab`. Upload this to Play Console; it should now be signed with the expected key.

---

## If you don’t have the keystore (SHA1 30:C8:A9:...)

If you no longer have the keystore that has SHA1 `30:C8:A9:63:E5:76:86:B4:17:CC:82:F6:13:BE:77:F4:C1:39:40:EE`, you cannot sign with that key again. You must:

1. **Request an upload key reset** in Google Play Console:
   - Open your app → **Setup** → **App signing** (or **Release** → **Setup** → **App signing**).
   - If you use Play App Signing, there is an option to **request an upload key reset** (e.g. “Request upload key reset” or “Contact support”).
   - Follow Google’s process (they may ask you to create a new key and submit a PEM or use the in-console wizard).

2. **Create a new upload keystore** (only after Google has approved the reset or instructed you to register a new key), then:
   - Put the new keystore in a safe place.
   - Create `android/key.properties` as above pointing to this new keystore.
   - Build the app bundle with `flutter build appbundle` and upload the new AAB.

Your project already contains guides such as `RESET_UPLOAD_KEY_STEPS.md` and `STEP_BY_STEP_UPLOAD_KEY_RESET.md` in the `android/` folder; use those for the exact Play Console steps.

---

## Summary

| Expected by Play   | SHA1: 30:C8:A9:63:E5:76:86:B4:17:CC:82:F6:13:BE:77:F4:C1:39:40:EE |
|--------------------|--------------------------------------------------------------------|
| What you uploaded  | SHA1: B3:DB:69:75:8B:A3:66:BA:D0:5C:77:2D:67:67:B0:26:AA:BE:40:26 (debug key) |
| Fix                | Create `android/key.properties` with the keystore that has the expected SHA1, then run `flutter build appbundle` and upload the new AAB. |

---

## FiksOpp keystores only (commands to run)

Run these and look for SHA1 `30:C8:A9:63:E5:76:86:B4:17:CC:82:F6:13:BE:77:F4:C1:39:40:EE`:

```bash
keytool -list -v -keystore /Users/mac/fiksOpp---User/android/app/keystore_new.jks
```

Or run: `bash android/list_keystore_sha1.sh` (prompts for password for each).

### Checked results (FiksOpp keystores)

| Keystore | SHA1 | Match? |
|----------|------|--------|
| `/Users/mac/fiksOpp---User/android/app/keystore.jks` | **Unreadable** — keytool fails (PKCS12: "lengthTag too big"; may be corrupted or wrong format). Cannot use. | — |
| `/Users/mac/fiksOpp---User/android/app/keystore_new.jks` | `D2:62:F2:83:23:8A:77:EC:...` Alias: `fiksop` | **No** |

**None of the FiksOpp keystores checked so far have the expected SHA1.** The key Play expects (`30:C8:A9:...`) is not among the keystores found on this Mac. You need to **request an upload key reset** in Google Play Console (see section above), then create a new upload key and register it with Play.

---

## Request upload key reset — what to upload

When you click **Request upload key reset** in Play Console, Google asks you to **upload a certificate (PEM file)**. You do **not** upload the keystore (.jks); you upload the **exported certificate** only.

### 1. Create a new upload keystore (once)

From the project root (use a strong password and remember it):

```bash
cd android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Enter the password and the requested details (name, org, city, country, etc.).

### 2. Export the certificate as PEM (this is what you upload)

```bash
keytool -export -rfc -keystore upload-keystore.jks -alias upload -file upload_certificate.pem
```

This creates **`android/app/upload_certificate.pem`**.

### 3. In Google Play Console

1. Open your app → **Release** → **Setup** → **App signing**.
2. Click **Request upload key reset** and choose a reason (e.g. “I lost my upload key”).
3. Where it asks for the new certificate, click **Upload** / **Choose file**.
4. Select **`upload_certificate.pem`** (from `android/app/upload_certificate.pem`).
5. Submit the request.

**Summary:** You upload **only** the **PEM file** (`upload_certificate.pem`). Keep the **keystore** (`upload-keystore.jks`) and its password private; use them in `android/key.properties` after Google approves the reset. See `android/RESET_UPLOAD_KEY_STEPS.md` for the full flow.
