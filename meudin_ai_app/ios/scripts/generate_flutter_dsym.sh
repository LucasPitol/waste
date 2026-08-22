#!/bin/sh
set -e

# App Store Connect (Xcode 16+) expects a dSYM for embedded Flutter.framework.
# Engine artifacts may ship without one, so generate it from the embedded binary.
if [ "${ACTION}" != "install" ] && [ "${ACTION}" != "archive" ]; then
  exit 0
fi

FLUTTER_BINARY="${TARGET_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}/Flutter.framework/Flutter"
DSYM_OUTPUT="${DWARF_DSYM_FOLDER_PATH}/Flutter.framework.dSYM"
PRECACHED_DSYM="${FLUTTER_ROOT}/bin/cache/artifacts/engine/ios-release/Flutter.xcframework/ios-arm64/dSYMs/Flutter.framework.dSYM"

if [ ! -f "${FLUTTER_BINARY}" ]; then
  echo "warning: Flutter.framework binary not found, skipping dSYM generation"
  exit 0
fi

if [ -d "${PRECACHED_DSYM}" ]; then
  echo "Copying Flutter.framework.dSYM from Flutter engine cache..."
  rm -rf "${DSYM_OUTPUT}"
  rsync -a "${PRECACHED_DSYM}" "${DWARF_DSYM_FOLDER_PATH}/"
else
  echo "Generating Flutter.framework.dSYM for archive..."
  rm -rf "${DSYM_OUTPUT}"
  xcrun dsymutil "${FLUTTER_BINARY}" -o "${DSYM_OUTPUT}"
fi
