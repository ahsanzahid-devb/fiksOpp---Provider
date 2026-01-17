# Upload Key Reset Guide

## Step 1: Request Upload Key Reset in Google Play Console

1. Go to **Google Play Console** → Your App → **App integrity** → **App signing**
2. Scroll down to the **Upload key certificate** section
3. Click **"Request upload key reset"** button
4. Follow Google's instructions to complete the reset process

## Step 2: After Reset - You'll Get a New Upload Key Certificate

After the reset is approved, Google Play will provide you with:
- A new **Upload key certificate** with a new SHA-1 fingerprint
- Instructions on how to generate a new upload keystore

## Step 3: Generate New Upload Keystore

After reset, you'll need to create a new keystore file. Google Play Console will provide specific instructions, but typically:

### Option A: Google Provides the Keystore
- Google may generate the keystore for you to download
- Download it and save it securely

### Option B: Generate Your Own Keystore
If you need to generate it yourself, use this command (adjust values as needed):

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Important:** The keystore you create must match the certificate fingerprint that Google Play Console shows after reset.

## Step 4: Update key.properties

Once you have the new keystore:

1. Place the keystore file in `android/app/` directory
2. Update `android/key.properties` with:
   - `storePassword`: Your keystore password
   - `keyPassword`: Your key password (usually same as storePassword)
   - `keyAlias`: Your key alias (e.g., "upload")
   - `storeFile`: Path to keystore (e.g., "app/upload-keystore.jks")

## Step 5: Verify the Keystore

Verify your new keystore matches the upload key certificate in Google Play Console:

```bash
keytool -list -v -keystore android/app/upload-keystore.jks -alias upload
```

Check that the SHA-1 fingerprint matches what Google Play Console shows.

## Step 6: Build and Upload

```bash
flutter build appbundle --release
```

Then upload the new app bundle to Google Play Console.

## Important Notes

⚠️ **Keep your new upload keystore safe!**
- Store it in a secure location
- Back it up multiple times
- Never commit it to version control (it's already in .gitignore)
- If you lose it, you'll need to request another reset

⚠️ **After reset:**
- You can no longer use the old upload key
- All future uploads must use the new upload key
- The app signing key (managed by Google) remains the same

