#!/bin/sh
set -eu

# Единственный переключатель находится в AppConstants.swift.
CRASHLYTICS_TEST_MODE=$(/usr/bin/sed -nE 's/^[[:space:]]*static let crashlyticsTestMode = (true|false)[[:space:]]*$/\1/p' "${SRCROOT}/Math_Tricks/AppConstants.swift")

case "$CRASHLYTICS_TEST_MODE" in
    true|false) ;;
    *) echo "error: AppConstants.crashlyticsTestMode must be a literal true or false."; exit 1 ;;
esac

if [ "$CRASHLYTICS_TEST_MODE" = true ]; then
    echo "Crashlytics: symbol upload skipped (test mode)."
    exit 0
fi

"${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"
