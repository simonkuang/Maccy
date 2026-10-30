#!/usr/bin/env bash
set -euo pipefail

# Build script for Simon's optimized Maccy build
# Generates Release universal binary with ad-hoc code signature

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/build"
APP_NAME="Maccy.app"
RELEASE_APP="${BUILD_DIR}/Release/${APP_NAME}"

echo "===> 1. Cleaning previous build output..."
rm -rf "${BUILD_DIR}"

echo "===> 2. Building ${APP_NAME} (Release configuration)..."
xcodebuild \
  -project "${PROJECT_DIR}/Maccy.xcodeproj" \
  -scheme Maccy \
  -configuration Release \
  -destination 'generic/platform=macOS' \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  BUILD_DIR="${BUILD_DIR}" \
  build

if [ ! -d "${RELEASE_APP}" ]; then
  echo "Error: Build succeeded but ${RELEASE_APP} not found!"
  exit 1
fi

echo "===> 3. Ad-hoc codesigning with deep recursion..."
codesign --force --deep --sign - "${RELEASE_APP}"

echo "===> 4. Verifying codesign signature..."
codesign -dv --verbose=2 "${RELEASE_APP}"

echo ""
echo "=========================================================="
echo "  Build & Signing Completed Successfully!"
echo "  Artifact: ${RELEASE_APP}"
echo "=========================================================="
