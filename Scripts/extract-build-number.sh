#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Extract build number from built .app bundle

set -e

# Colors for output
RED='\033[0;31m'
# shellcheck disable=SC2034
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") <path_to_app>

Extract the CFBundleVersion (build number) from an app bundle

Arguments:
    path_to_app     Path to the .app bundle or DMG file

Examples:
    $(basename "$0") build/Release/AeroSpaceBar.app
    $(basename "$0") AeroSpaceBar.dmg
EOF
}

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Missing app path argument${NC}" >&2
    echo ""
    usage
    exit 1
fi

APP_PATH="$1"
TEMP_MOUNT=""

# Cleanup function for DMG
cleanup() {
    if [ -n "$TEMP_MOUNT" ] && [ -d "$TEMP_MOUNT" ]; then
        echo -e "${YELLOW}Cleaning up temporary mount...${NC}"
        hdiutil detach "$TEMP_MOUNT" -quiet 2>/dev/null || true
    fi
}

trap cleanup EXIT

# Check if input is a DMG file
if [[ "$APP_PATH" == *.dmg ]]; then
    if [ ! -f "$APP_PATH" ]; then
        echo -e "${RED}Error: DMG file not found: $APP_PATH${NC}" >&2
        exit 1
    fi

    echo -e "${YELLOW}Mounting DMG: $APP_PATH${NC}"

    # Mount the DMG
    TEMP_MOUNT=$(mktemp -d)
    if ! hdiutil attach "$APP_PATH" -mountpoint "$TEMP_MOUNT" -quiet -readonly; then
        echo -e "${RED}Error: Failed to mount DMG${NC}" >&2
        exit 1
    fi

    # Find the .app bundle in the mounted DMG
    APP_BUNDLE=$(find "$TEMP_MOUNT" -name "*.app" -maxdepth 1 | head -n 1)

    if [ -z "$APP_BUNDLE" ]; then
        echo -e "${RED}Error: No .app bundle found in DMG${NC}" >&2
        exit 1
    fi

    APP_PATH="$APP_BUNDLE"
fi

# Check if the app bundle exists
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}Error: App bundle not found: $APP_PATH${NC}" >&2
    exit 1
fi

# Find Info.plist
INFO_PLIST="$APP_PATH/Contents/Info.plist"

if [ ! -f "$INFO_PLIST" ]; then
    echo -e "${RED}Error: Info.plist not found at: $INFO_PLIST${NC}" >&2
    exit 1
fi

# Extract build number
BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFO_PLIST" 2>/dev/null || echo "")

if [ -z "$BUILD_NUMBER" ]; then
    echo -e "${RED}Error: Could not read CFBundleVersion from Info.plist${NC}" >&2
    exit 1
fi

# Validate build number is numeric
if [[ ! "$BUILD_NUMBER" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: Build number is not a valid integer: $BUILD_NUMBER${NC}" >&2
    exit 1
fi

# Output the build number
echo "$BUILD_NUMBER"
