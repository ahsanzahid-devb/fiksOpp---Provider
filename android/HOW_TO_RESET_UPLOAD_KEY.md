# How to Reset Upload Key in Google Play Console

## ⚠️ IMPORTANT: You Need to Reset the UPLOAD KEY, NOT the App Signing Key

The dialog you're seeing is for "Upgrade app signing key" - **DO NOT use this!**

You need to reset the **Upload key**, which is different.

## Correct Steps:

### Step 1: Navigate to Upload Key Section
1. In Google Play Console, go to: **App integrity** → **App signing**
2. Scroll down to the section titled **"Upload key certificate"** (NOT "App signing key certificate")
3. Look for the button that says **"Request upload key reset"**

### Step 2: Request Upload Key Reset
1. Click **"Request upload key reset"** button
2. Google will ask you to verify your identity (this is a security measure)
3. You may need to:
   - Verify your email
   - Answer security questions
   - Wait for Google's approval (can take a few days)

### Step 3: After Reset is Approved
Once Google approves the reset:
1. You'll see a **NEW upload key certificate** with a different SHA-1 fingerprint
2. Google will provide instructions on how to generate/use the new upload key
3. You'll need to create a new keystore that matches this new certificate

### Step 4: Generate New Keystore
After you get the new upload key certificate from Google:

**Option A: If Google provides a keystore**
- Download it and save it securely
- Place it in `android/app/` directory

**Option B: If you need to generate it yourself**
- Use the script: `android/generate_upload_keystore.bat` (Windows)
- Or manually: `keytool -genkey -v -keystore android/app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
- **Important:** The SHA-1 fingerprint must match what Google Play Console shows after reset

### Step 5: Update Configuration
Update `android/key.properties` with your new keystore details:
```
storePassword=your_password
keyPassword=your_password
keyAlias=upload
storeFile=app/upload-keystore.jks
```

### Step 6: Verify and Build
```bash
# Verify SHA-1 matches Google Play Console
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload

# Build app bundle
flutter build appbundle --release
```

## Visual Guide:

```
Google Play Console
└── App integrity
    └── App signing
        ├── App signing key certificate ← DON'T TOUCH THIS
        │   └── (This is managed by Google)
        │
        └── Upload key certificate ← GO HERE!
            └── "Request upload key reset" button ← CLICK THIS!
```

## Current Upload Key (Before Reset):
- SHA-1: `27:56:1B:BC:6E:4A:FA:6D:4E:F7:1B:34:88:A1:CC:E4:45:74:32:9F`
- This is the one you're trying to match, but your current bundle has a different key

## After Reset:
- You'll get a NEW SHA-1 fingerprint
- Your new keystore must match this NEW fingerprint
- You can no longer use the old upload key

