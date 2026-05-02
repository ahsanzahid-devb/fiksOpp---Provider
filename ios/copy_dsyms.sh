#!/bin/bash

# Copies vendor dSYMs bundled inside xcframeworks into the archive dSYMs folder.
# App Store symbol validation expects these files to be present in the final archive.

set -euo pipefail

if [ "${CONFIGURATION}" != "Release" ]; then
  exit 0
fi

if [ -z "${DWARF_DSYM_FOLDER_PATH:-}" ] || [ ! -d "${DWARF_DSYM_FOLDER_PATH}" ]; then
  echo "Skipping dSYM copy: DWARF_DSYM_FOLDER_PATH is missing."
  exit 0
fi

ARCHIVE_DSYMS_PATH="${DWARF_DSYM_FOLDER_PATH}"
PODS_ROOT_PATH="${PODS_ROOT:-${SRCROOT}/Pods}"

copy_if_exists() {
  local source_path="$1"
  if [ -d "${source_path}" ]; then
    echo "Copying $(basename "${source_path}")"
    cp -R "${source_path}" "${ARCHIVE_DSYMS_PATH}/"
  fi
}

# Razorpay pods bundle dSYMs inside xcframework slices.
copy_if_exists "${PODS_ROOT_PATH}/razorpay-core-pod/Pod/core/Razorpay.xcframework/ios-arm64/dSYMs/Razorpay.framework.dSYM"
copy_if_exists "${PODS_ROOT_PATH}/razorpay-core-pod/Pod/core/RazorpayCore.xcframework/ios-arm64/dSYMs/RazorpayCore.framework.dSYM"
copy_if_exists "${PODS_ROOT_PATH}/razorpay-pod/Pod/RazorpayStandard.xcframework/ios-arm64/dSYMs/RazorpayStandard.framework.dSYM"

# PhonePePayment 4.0.0 pod does not ship iOS dSYMs. Keep visible log for release notes.
if [ -d "${PODS_ROOT_PATH}/PhonePePayment/PhonePePayment.xcframework" ]; then
  echo "PhonePePayment.xcframework detected (no bundled dSYM in current pod version)."
fi
