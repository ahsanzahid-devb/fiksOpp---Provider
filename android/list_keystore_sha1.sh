#!/bin/bash
# List SHA1 of FiksOpp keystores only (run from android/ or project root).
# You will be prompted for the keystore password for each file.

EXPECTED="30:C8:A9:63:E5:76:86:B4:17:CC:82:F6:13:BE:77:F4:C1:39:40:EE"

echo "Expected SHA1 (use this key for Play upload): $EXPECTED"
echo ""

# keystore.jks is unreadable (keytool fails). Only check keystore_new.jks.
for keystore in \
  /Users/mac/fiksOpp---User/android/app/keystore_new.jks \
  ; do
  if [ -f "$keystore" ]; then
    echo "--- $keystore ---"
    keytool -list -v -keystore "$keystore" 2>/dev/null | grep -E "Alias name|SHA1:"
    echo ""
  fi
done

echo "If a keystore above shows SHA1: $EXPECTED, use that keystore in android/key.properties"
