#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Notarize AeroSpaceBar.app with Apple

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
APP_PATH=""
SKIP_STAPLE=false

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [options] <app_path>

Notarize AeroSpaceBar.app with Apple using notarytool

Arguments:
    app_path                Path to the .app bundle to notarize

Options:
    --skip-staple           Skip stapling the notarization ticket
    -h, --help              Show this help message

Prerequisites:
    - App must be code signed
    - Apple ID credentials configured with 'xcrun notarytool store-credentials'
    - Or set environment variables: NOTARIZATION_APPLE_ID, NOTARIZATION_PASSWORD, NOTARIZATION_TEAM_ID

Examples:
    $(basename "$0") build/Release/AeroSpaceBar.app
    $(basename "$0") --skip-staple build/Release/AeroSpaceBar.app
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-staple)
            SKIP_STAPLE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo -e "${RED}Error: Unknown option: $1${NC}" >&2
            usage
            exit 1
            ;;
        *)
            APP_PATH="$1"
            shift
            ;;
    esac
done

# Check if app path is provided
if [ -z "$APP_PATH" ]; then
    echo -e "${RED}Error: Missing app path argument${NC}" >&2
    usage
    exit 1
fi

# Check if app exists
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}Error: App bundle not found: $APP_PATH${NC}" >&2
    exit 1
fi

# Verify app is signed
if ! codesign --verify "$APP_PATH" 2>/dev/null; then
    echo -e "${RED}Error: App is not properly code signed${NC}" >&2
    echo -e "${YELLOW}Run scripts/codesign-app.sh first${NC}" >&2
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Notarizing AeroSpaceBar${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "App path: ${GREEN}$APP_PATH${NC}"
echo ""

# Create a temporary ZIP for notarization
echo -e "${BLUE}1. Creating ZIP archive for notarization...${NC}"
TEMP_ZIP=$(mktemp -d)/AeroSpaceBar.zip
# shellcheck disable=SC2064
trap "rm -f $TEMP_ZIP" EXIT

cd "$(dirname "$APP_PATH")"
ZIP_APP_NAME=$(basename "$APP_PATH")
if ! /usr/bin/ditto -c -k --keepParent "$ZIP_APP_NAME" "$TEMP_ZIP"; then
    echo -e "${RED}Error: Failed to create ZIP archive${NC}" >&2
    exit 1
fi

ZIP_SIZE=$(du -h "$TEMP_ZIP" | cut -f1)
echo -e "${GREEN}✓ Created ZIP: $ZIP_SIZE${NC}"

# Submit for notarization
echo ""
echo -e "${BLUE}2. Submitting to Apple for notarization...${NC}"
echo -e "${YELLOW}This may take several minutes...${NC}"

# Try to use stored credentials first, fallback to environment variables
if xcrun notarytool history --keychain-profile "aerospacebar" >/dev/null 2>&1; then
    NOTARYTOOL_ARGS=(--keychain-profile "aerospacebar")
elif [ -n "${NOTARIZATION_APPLE_ID:-}" ] && [ -n "${NOTARIZATION_PASSWORD:-}" ] && [ -n "${NOTARIZATION_TEAM_ID:-}" ]; then
    NOTARYTOOL_ARGS=(
        --apple-id "$NOTARIZATION_APPLE_ID"
        --password "$NOTARIZATION_PASSWORD"
        --team-id "$NOTARIZATION_TEAM_ID"
    )
else
    echo -e "${RED}Error: Notarization credentials not configured${NC}" >&2
    echo -e "${YELLOW}Run: xcrun notarytool store-credentials --apple-id <apple-id> --team-id <team-id>${NC}" >&2
    echo -e "${YELLOW}Or set environment variables: NOTARIZATION_APPLE_ID, NOTARIZATION_PASSWORD, NOTARIZATION_TEAM_ID${NC}" >&2
    exit 1
fi

if xcrun notarytool submit "$TEMP_ZIP" "${NOTARYTOOL_ARGS[@]}" --wait; then
    echo ""
    echo -e "${GREEN}✓ Notarization successful!${NC}"
else
    echo ""
    echo -e "${RED}✗ Notarization failed${NC}" >&2
    echo -e "${YELLOW}Check notarization log for details${NC}" >&2
    exit 1
fi

# Staple the notarization ticket
if [ "$SKIP_STAPLE" = false ]; then
    echo ""
    echo -e "${BLUE}3. Stapling notarization ticket...${NC}"
    if xcrun stapler staple "$APP_PATH"; then
        echo -e "${GREEN}✓ Notarization ticket stapled${NC}"
    else
        echo -e "${YELLOW}⚠ Failed to staple ticket (app is still notarized)${NC}"
    fi
fi

# Verify with Gatekeeper
echo ""
echo -e "${BLUE}4. Verifying with Gatekeeper...${NC}"
if spctl --assess --type execute --verbose "$APP_PATH" 2>&1 | grep -q "accepted"; then
    echo -e "${GREEN}✓ App accepted by Gatekeeper${NC}"
else
    echo -e "${YELLOW}⚠ Gatekeeper assessment warning (may still work)${NC}"
fi

echo ""
echo -e "${GREEN}✅ Notarization completed successfully!${NC}"
