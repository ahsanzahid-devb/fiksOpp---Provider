# How to Verify Your Keystore SHA-1 Fingerprint

## Windows (PowerShell/Command Prompt)

If you find a keystore file, verify its SHA-1 fingerprint matches:
`27:56:1B:BC:6E:4A:FA:6D:4E:F7:1B:34:88:A1:CC:E4:45:74:32:9F`

### Command:
```bash
keytool -list -v -keystore "path/to/your/keystore.jks" -alias "your_key_alias"
```

Or if you don't know the alias:
```bash
keytool -list -v -keystore "path/to/your/keystore.jks"
```

### Look for:
- SHA1: 27:56:1B:BC:6E:4A:FA:6D:4E:F7:1B:34:88:A1:CC:E4:45:74:32:9F

If it matches, that's your upload key!

