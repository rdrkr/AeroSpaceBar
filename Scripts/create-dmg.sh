#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Create a distributable DMG file

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
APP_PATH=""
OUTPUT_PATH=""

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") <app_path> [output_path]

Create a distributable DMG file for AeroSpaceBar

Arguments:
    app_path        Path to the .app bundle
    output_path     Optional output path for DMG (default: same directory as app)

Examples:
    $(basename "$0") build/Release/AeroSpaceBar.app
    $(basename "$0") build/Release/AeroSpaceBar.app dist/AeroSpaceBar.dmg
EOF
}

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Missing app path argument${NC}" >&2
    usage
    exit 1
fi

APP_PATH="$1"
OUTPUT_PATH="${2:-}"

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}Error: App bundle not found: $APP_PATH${NC}" >&2
    exit 1
fi

# Get app version
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist" 2>/dev/null || echo "1.0.0")

# Determine output path
if [ -z "$OUTPUT_PATH" ]; then
    APP_DIR=$(dirname "$APP_PATH")
    OUTPUT_PATH="$APP_DIR/AeroSpaceBar-v$VERSION.dmg"
fi

# Remove existing DMG
if [ -f "$OUTPUT_PATH" ]; then
    echo -e "${YELLOW}Removing existing DMG: $OUTPUT_PATH${NC}"
    rm -f "$OUTPUT_PATH"
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Creating DMG${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "App:     ${GREEN}$APP_PATH${NC}"
echo -e "Version: ${GREEN}$VERSION${NC}"
echo -e "Output:  ${GREEN}$OUTPUT_PATH${NC}"
echo ""

# Create temporary directory for DMG contents
TEMP_DIR=$(mktemp -d)
# shellcheck disable=SC2064
trap "rm -rf $TEMP_DIR" EXIT

echo -e "${BLUE}1. Preparing DMG contents...${NC}"

# Copy app to temp directory
cp -R "$APP_PATH" "$TEMP_DIR/"

# Create Applications symlink
ln -s /Applications "$TEMP_DIR/Applications"

echo -e "${GREEN}✓ DMG contents prepared${NC}"
echo ""

# Create the DMG
echo -e "${BLUE}2. Creating DMG file...${NC}"

if hdiutil create \
    -volname "AeroSpaceBar $VERSION" \
    -srcfolder "$TEMP_DIR" \
    -ov \
    -format UDZO \
    -fs HFS+ \
    "$OUTPUT_PATH"; then

    echo -e "${GREEN}✓ DMG created${NC}"
else
    echo -e "${RED}✗ Failed to create DMG${NC}" >&2
    exit 1
fi

# Get DMG size
DMG_SIZE=$(du -h "$OUTPUT_PATH" | cut -f1)
echo -e "${GREEN}Size: ${BLUE}$DMG_SIZE${NC}"

# Verify DMG
echo ""
echo -e "${BLUE}3. Verifying DMG...${NC}"

# Mount DMG to verify
MOUNT_POINT=$(mktemp -d)
if hdiutil attach "$OUTPUT_PATH" -mountpoint "$MOUNT_POINT" -quiet -readonly; then
    if [ -d "$MOUNT_POINT/AeroSpaceBar.app" ]; then
        echo -e "${GREEN}✓ DMG is valid${NC}"
    else
        echo -e "${RED}✗ App not found in DMG${NC}" >&2
        hdiutil detach "$MOUNT_POINT" -quiet
        exit 1
    fi
    hdiutil detach "$MOUNT_POINT" -quiet
    rmdir "$MOUNT_POINT"
else
    echo -e "${RED}✗ Could not mount DMG${NC}" >&2
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ DMG Created Successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "Location: ${BLUE}$OUTPUT_PATH${NC}"
echo -e "Size:     ${BLUE}$DMG_SIZE${NC}"
