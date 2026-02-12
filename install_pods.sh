#!/bin/bash
# Install iOS CocoaPods (fixes BoringSSL-GRPC clone and Generated.xcconfig).
#
# Run from Terminal (not Cursor) from project root:
#   chmod +x install_pods.sh
#   ./install_pods.sh

set -e
cd "$(dirname "$0")"

echo "Step 1: Flutter pub get (creates ios/Flutter/Generated.xcconfig)..."
flutter pub get

echo ""
echo "Step 2: Git config (fixes BoringSSL-GRPC clone / LibreSSL errors)..."
git config --global http.postBuffer 524288000 2>/dev/null || true
git config --global http.version HTTP/1.1 2>/dev/null || true

echo ""
echo "Step 3: Pod install (retrying up to 3 times on network errors)..."
cd ios
for attempt in 1 2 3; do
  echo "Attempt $attempt of 3..."
  if pod install; then
    echo "Pod install succeeded."
    break
  fi
  if [ "$attempt" -eq 3 ]; then
    echo "Pod install failed after 3 attempts."
    echo "Try: pod cache clean --all && rm -rf ~/Library/Caches/CocoaPods && pod install"
    exit 1
  fi
  echo "Retrying in 10 seconds..."
  sleep 10
done
cd ..

echo ""
echo "Done. You can now run: flutter build ipa"
