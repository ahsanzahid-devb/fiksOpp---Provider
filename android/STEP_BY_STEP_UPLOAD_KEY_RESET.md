# Step-by-Step Upload Key Reset Process

## Current Situation
- **Current Upload Key SHA-1**: `27:56:1B:BC:6E:4A:FA:6D:4E:F7:1B:34:88:A1:CC:E4:45:74:32:9F`
- **Your Bundle SHA-1**: `E3:69:91:79:86:DD:56:E6:AB:AB:81:38:EE:3D:66:1E:A3:8F:10:4B` (doesn't match)
- **Solution**: Generate a new upload key and reset it in Google Play Console

## Step 1: Generate New Upload Keystore

Open terminal/command prompt in the `android` directory and run:

### Windows:
```bash
cd android
keytool -genkey -v -keystore app\upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Mac/Linux:
```bash
cd android
keytool -genkey -v -keystore app/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**When prompted, enter:**
- **Keystore password**: Choose a strong password (remember this!)
- **Re-enter password**: Same password
- **First and last name**: Your name or company name
- **Organizational unit**: Your department (optional)
- **Organization**: Your company name
- **City**: Your city
- **State**: Your state/province
- **Country code**: Two-letter code (e.g., US, IN, GB)
- **Confirm**: Type 'yes'

**IMPORTANT**: Save the password and alias name securely!

## Step 2: Export Certificate as PEM File

After generating the keystore, export the certificate:

### Windows:
```bash
keytool -export -rfc -keystore app\upload-keystore.jks -alias upload -file app\upload_certificate.pem
```

### Mac/Linux:
```bash
keytool -export -rfc -keystore app/upload-keystore.jks -alias upload -file app/upload_certificate.pem
```

Enter the keystore password when prompted.

This creates `android/app/upload_certificate.pem` file.

## Step 3: Verify the Certificate

Check the SHA-1 fingerprint of your new certificate:

### Windows:
```bash
keytool -list -v -keystore app\upload-keystore.jks -alias upload
```

### Mac/Linux:
```bash
keytool -list -v -keystore app/upload-keystore.jks -alias upload
```

**Note the SHA-1 fingerprint** - this will be different from the current one.

## Step 4: Submit to Google Play Console

1. **Select reason**: In the Google Play Console form, select:
   - "I lost my upload key" (if you can't find the old one)
   - OR "Other" (if you have another reason)

2. **Upload the PEM certificate**:
   - Click "Choose file" or drag and drop
   - Select: `android/app/upload_certificate.pem`
   - Upload it

3. **Submit the request**

## Step 5: Wait for Approval

- Google will review your request
- This can take **1-3 business days**
- You'll receive an email when approved

## Step 6: After Approval

Once approved:

1. **Update `android/key.properties`** with your new keystore details:
   ```
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyPassword=YOUR_KEY_PASSWORD
   keyAlias=upload
   storeFile=app/upload-keystore.jks
   ```

2. **Build your app bundle**:
   ```bash
   flutter build appbundle --release
   ```

3. **Upload to Google Play Console** - it should now accept your bundle!

## Important Notes

⚠️ **Keep your new keystore safe!**
- Location: `android/app/upload-keystore.jks`
- Password: Store it securely (password manager recommended)
- Backup: Make multiple backups in secure locations
- Never commit to Git (already in .gitignore)

⚠️ **After reset:**
- You can ONLY use the new upload key
- The old upload key will no longer work
- All future uploads must use the new keystore

## Troubleshooting

**If keytool command not found:**
- Make sure Java JDK is installed
- Add Java bin directory to your PATH
- Or use full path: `C:\Program Files\Java\jdk-XX\bin\keytool.exe`

**If permission denied:**
- Make sure you have write permissions in the `android/app/` directory
- Try running as administrator (Windows) or with sudo (Mac/Linux)

