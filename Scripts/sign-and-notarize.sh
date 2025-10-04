#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Combined code signing and notarization workflow

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
# shellcheck disable=SC2034
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default values
APP_PATH=""
SIGNING_IDENTITY=""
SKIP_STAPLE=false

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [options] <app_path>

Combined code signing and notarization workflow for AeroSpaceBar

Arguments:
    app_path                Path to the .app bundle

Options:
    -i, --identity <name>   Signing identity (default: auto-detect)
    --skip-staple           Skip stapling the notarization ticket
    -h, --help              Show this help message

Examples:
    $(basename "$0") build/Release/AeroSpaceBar.app
    $(basename "$0") -i "Developer ID Application: Your Name" build/Release/AeroSpaceBar.app
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--identity)
            SIGNING_IDENTITY="$2"
            shift 2
            ;;
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

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Sign and Notarize AeroSpaceBar${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "App path: ${GREEN}$APP_PATH${NC}"
echo ""

# Step 1: Code signing
echo -e "${BLUE}Step 1: Code Signing${NC}"
echo -e "${BLUE}========================================${NC}"

CODESIGN_ARGS=("$APP_PATH")
if [ -n "$SIGNING_IDENTITY" ]; then
    CODESIGN_ARGS=(-i "$SIGNING_IDENTITY" "${CODESIGN_ARGS[@]}")
fi

if ! bash "$SCRIPT_DIR/codesign-app.sh" "${CODESIGN_ARGS[@]}"; then
    echo -e "${RED}✗ Code signing failed${NC}" >&2
    exit 1
fi

echo ""

# Step 2: Notarization
echo -e "${BLUE}Step 2: Notarization${NC}"
echo -e "${BLUE}========================================${NC}"

NOTARIZE_ARGS=("$APP_PATH")
if [ "$SKIP_STAPLE" = true ]; then
    NOTARIZE_ARGS=(--skip-staple "${NOTARIZE_ARGS[@]}")
fi

if ! bash "$SCRIPT_DIR/notarize-app.sh" "${NOTARIZE_ARGS[@]}"; then
    echo -e "${RED}✗ Notarization failed${NC}" >&2
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Sign and Notarize Completed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "The app is now signed and notarized"
echo -e "Ready for distribution"
