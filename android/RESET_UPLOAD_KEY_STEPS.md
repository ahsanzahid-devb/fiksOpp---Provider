# Step-by-Step: Reset Upload Key Process

## Current Status
You're in the "Request upload key reset" dialog in Google Play Console.

## Step 1: Select Reason
Choose one of the reasons:
- ✅ **"I lost my upload key"** (Most common)
- "Developer with access to the keystore has left my company"
- "My upload key has been compromised"
- "I forgot the password to my keystore"
- "Other"

## Step 2: Generate New Upload Key

Google is asking you to generate a new keystore and export the certificate.

### Run this command in your terminal:

```bash
cd android/app
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**You'll be asked for:**
- Keystore password (remember this!)
- Re-enter password
- Your name
- Organizational unit
- Organization
- City
- State/Province
- Country code (2 letters, e.g., US, IN, PK)

**Important:** Remember the password you set - you'll need it later!

## Step 3: Export Certificate as PEM

After generating the keystore, export the certificate:

```bash
cd android/app
keytool -export -rfc -keystore upload-keystore.jks -alias upload -file upload_certificate.pem
```

This creates `upload_certificate.pem` file.

## Step 4: Upload to Google Play Console

1. In the Google Play Console dialog, you'll see an option to upload the PEM file
2. Click "Choose File" or "Upload"
3. Select the `upload_certificate.pem` file from `android/app/` directory
4. Submit the request

## Step 5: Wait for Approval

- Google will review your request
- This can take a few hours to a few days
- You'll receive an email when approved

## Step 6: After Approval

Once approved:
1. The new upload key certificate will appear in Google Play Console
2. Note the new SHA-1 fingerprint
3. Update `android/key.properties` with your keystore details
4. Build and upload your app bundle

## Step 7: Update key.properties

After approval, update `android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=app/upload-keystore.jks
```

## Step 8: Build App Bundle

```bash
flutter build appbundle --release
```

Then upload to Google Play Console - it should work now!

