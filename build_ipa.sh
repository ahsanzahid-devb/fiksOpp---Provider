#!/bin/bash
# Build IPA for App Store upload
#
# IMPORTANT: Run this from Terminal (macOS), NOT from Cursor's integrated terminal.
# CocoaPods uses a cache that gets corrupted when run from Cursor's environment.
#
# From project root: ./build_ipa.sh

set -e
cd "$(dirname "$0")"

echo "Cleaning CocoaPods cache (fixes JSON parse errors)..."
pod cache clean --all 2>/dev/null || true
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks
rm -rf ~/Library/Caches/CocoaPods 2>/dev/null || true

# Use system temp so CocoaPods doesn't use a corrupted cache
export TMPDIR=/tmp
export TEMP=/tmp
export TMP=/tmp

# Fix BoringSSL-GRPC clone: "HTTP/2 stream was not closed cleanly" (use HTTP/1.1)
git config --global http.version HTTP/1.1 2>/dev/null || true
# Help large git clones succeed; 500MB buffer
git config --global http.postBuffer 524288000 2>/dev/null || true
git config --global http.lowSpeedLimit 0
git config --global http.lowSpeedTime 999999

echo "Updating CocoaPods repo and installing pods (retrying up to 3 times on network errors)..."
cd ios
pod repo update
for attempt in 1 2 3; do
  echo "Pod install attempt $attempt of 3..."
  if pod install; then
    echo "Pod install succeeded."
    break
  fi
  if [ "$attempt" -eq 3 ]; then
    echo "Pod install failed after 3 attempts. Check your network and try again."
    exit 1
  fi
  echo "Retrying in 10 seconds..."
  sleep 10
done
cd ..

echo "Building IPA (this may take several minutes)..."
flutter build ipa

echo ""
echo "Done. IPA location:"
echo "  build/ios/ipa/"
ls -la build/ios/ipa/ 2>/dev/null || true
