#!/bin/bash

# Script to copy dSYMs from Pods to the archive's dSYMs folder
# This helps resolve missing dSYM warnings for third-party frameworks

set -e

ARCHIVE_DSYMS_PATH="${DWARF_DSYM_FOLDER_PATH}"
PODS_BUILD_DIR="${BUILD_DIR}/../Pods.build"

echo "Copying dSYMs from Pods to archive..."

# Copy dSYMs for PhonePePayment if they exist
if [ -d "${PODS_BUILD_DIR}/Release-iphoneos/PhonePePayment/PhonePePayment.framework.dSYM" ]; then
    echo "Found PhonePePayment.dSYM"
    cp -R "${PODS_BUILD_DIR}/Release-iphoneos/PhonePePayment/PhonePePayment.framework.dSYM" "${ARCHIVE_DSYMS_PATH}/" || true
fi

# Copy dSYMs for Razorpay if they exist
if [ -d "${PODS_BUILD_DIR}/Release-iphoneos/razorpay-pod/razorpay-pod.framework.dSYM" ]; then
    echo "Found Razorpay.dSYM"
    cp -R "${PODS_BUILD_DIR}/Release-iphoneos/razorpay-pod/razorpay-pod.framework.dSYM" "${ARCHIVE_DSYMS_PATH}/" || true
fi

# Copy dSYMs for objective_c if they exist (usually part of another framework)
if [ -d "${PODS_BUILD_DIR}/Release-iphoneos/objective_c/objective_c.framework.dSYM" ]; then
    echo "Found objective_c.dSYM"
    cp -R "${PODS_BUILD_DIR}/Release-iphoneos/objective_c/objective_c.framework.dSYM" "${ARCHIVE_DSYMS_PATH}/" || true
fi

# Also check in the derived data path
DERIVED_DATA="${BUILD_DIR%/Build/*}"
if [ -d "${DERIVED_DATA}/Build/Products/Release-iphoneos" ]; then
    find "${DERIVED_DATA}/Build/Products/Release-iphoneos" -name "*.dSYM" -exec cp -R {} "${ARCHIVE_DSYMS_PATH}/" \; || true
fi

echo "dSYM copy completed"
