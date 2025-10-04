#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Get current version and build number from Xcode project

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
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
XCODEPROJ="$PROJECT_ROOT/AeroSpaceBar.xcodeproj/project.pbxproj"

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [options]

Get current version and build number from Xcode project settings

Options:
    -v, --version           Show version only
    -b, --build            Show build number only
    -f, --full             Show full version string (default)
    --verify               Verify Xcode project version settings exist
    -h, --help             Show this help message

Examples:
    $(basename "$0")                  # Output: 1.0.0 (100)
    $(basename "$0") --version        # Output: 1.0.0
    $(basename "$0") --build          # Output: 100
    $(basename "$0") --verify         # Verify version settings
EOF
}

# Check if Xcode project exists
if [ ! -f "$XCODEPROJ" ]; then
    echo -e "${RED}Error: Xcode project file not found at $XCODEPROJ${NC}" >&2
    exit 1
fi

# Extract MARKETING_VERSION and CURRENT_PROJECT_VERSION for main app target
# These appear in the build configuration section before PRODUCT_BUNDLE_IDENTIFIER
VERSION=$(grep -B 50 "PRODUCT_BUNDLE_IDENTIFIER = com.rdrkr.AeroSpaceBar;" "$XCODEPROJ" | grep "MARKETING_VERSION" | head -n 1 | sed 's/.*MARKETING_VERSION = \(.*\);/\1/' | tr -d ' ;')
BUILD=$(grep -B 50 "PRODUCT_BUNDLE_IDENTIFIER = com.rdrkr.AeroSpaceBar;" "$XCODEPROJ" | grep "CURRENT_PROJECT_VERSION" | head -n 1 | sed 's/.*CURRENT_PROJECT_VERSION = \(.*\);/\1/' | tr -d ' ;')

# Validate extracted values
if [ -z "$VERSION" ]; then
    echo -e "${RED}Error: Could not read MARKETING_VERSION from Xcode project${NC}" >&2
    exit 1
fi

if [ -z "$BUILD" ]; then
    echo -e "${RED}Error: Could not read CURRENT_PROJECT_VERSION from Xcode project${NC}" >&2
    exit 1
fi

# Parse command line arguments
case "${1:-}" in
    -v|--version)
        echo "$VERSION"
        ;;
    -b|--build)
        echo "$BUILD"
        ;;
    -f|--full|"")
        echo "$VERSION ($BUILD)"
        ;;
    --verify)
        echo -e "${BLUE}Verifying version settings...${NC}"
        echo -e "Xcode project:   ${GREEN}$VERSION ($BUILD)${NC}"
        if [ -n "$VERSION" ] && [ -n "$BUILD" ]; then
            echo -e "${GREEN}✓ Version settings found${NC}"
            exit 0
        else
            echo -e "${RED}✗ Version settings missing or invalid${NC}"
            exit 1
        fi
        ;;
    -h|--help)
        usage
        exit 0
        ;;
    *)
        echo -e "${RED}Error: Unknown option: $1${NC}" >&2
        echo ""
        usage
        exit 1
        ;;
esac
