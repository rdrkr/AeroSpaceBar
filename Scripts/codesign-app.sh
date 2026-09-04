#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Code sign AeroSpaceBar.app with proper entitlements

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default values
APP_PATH=""
SIGNING_IDENTITY=""

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [options] <app_path>

Code sign AeroSpaceBar.app with proper entitlements and Sparkle framework signing

Arguments:
    app_path                Path to the .app bundle to sign

Options:
    -i, --identity <name>   Signing identity (default: auto-detect Developer ID Application)
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

# Auto-detect signing identity if not provided
#
# "Developer ID Application" is preferred because that is what distribution
# builds are signed with, and it is the certificate CI imports from the
# CERTIFICATES_P12 secret. "Apple Development" is only a fallback so that a
# local build still works on a machine that has just a development certificate.
if [ -z "$SIGNING_IDENTITY" ]; then
    AVAILABLE_IDENTITIES=$(security find-identity -v -p codesigning)

    for CERTIFICATE_TYPE in "Developer ID Application" "Apple Development"; do
        SIGNING_IDENTITY=$(echo "$AVAILABLE_IDENTITIES" | grep "$CERTIFICATE_TYPE" | head -n 1 | sed 's/.*"\(.*\)"/\1/')
        if [ -n "$SIGNING_IDENTITY" ]; then
            break
        fi
    done

    if [ -z "$SIGNING_IDENTITY" ]; then
        echo -e "${RED}Error: No 'Developer ID Application' or 'Apple Development' certificate found${NC}" >&2
        echo -e "${YELLOW}Identities visible to this process:${NC}" >&2
        echo "$AVAILABLE_IDENTITIES" >&2
        exit 1
    fi
    echo -e "${BLUE}Auto-detected signing identity:${NC}"
    echo -e "${GREEN}  $SIGNING_IDENTITY${NC}"
fi

# Get app bundle identifier
BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$APP_PATH/Contents/Info.plist" 2>/dev/null || echo "")
if [ -z "$BUNDLE_ID" ]; then
    echo -e "${RED}Error: Could not read bundle identifier from app${NC}" >&2
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Code Signing AeroSpaceBar${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "App path:      ${GREEN}$APP_PATH${NC}"
echo -e "Bundle ID:     ${GREEN}$BUNDLE_ID${NC}"
echo -e "Identity:      ${GREEN}$SIGNING_IDENTITY${NC}"
echo ""

# Entitlements file
ENTITLEMENTS_FILE="$PROJECT_ROOT/AeroSpaceBar/AeroSpaceBar.entitlements"
if [ ! -f "$ENTITLEMENTS_FILE" ]; then
    echo -e "${YELLOW}Warning: Entitlements file not found at $ENTITLEMENTS_FILE${NC}"
    ENTITLEMENTS_FILE=""
fi

# Sign frameworks and bundles first (depth-first signing)
echo -e "${BLUE}1. Signing embedded frameworks and XPC services...${NC}"

# Find and sign all frameworks
find "$APP_PATH/Contents/Frameworks" -name "*.framework" -type d 2>/dev/null | while read -r framework; do
    echo -e "   ${YELLOW}→${NC} Signing $(basename "$framework")"
    codesign --force --sign "$SIGNING_IDENTITY" \
        --options runtime \
        --timestamp \
        "$framework"
done

# Sign Sparkle XPC services with special entitlements
if [ -d "$APP_PATH/Contents/Frameworks/Sparkle.framework" ]; then
    echo -e "${BLUE}2. Signing Sparkle XPC services...${NC}"

    # Create temporary entitlements for XPC services
    XPC_ENTITLEMENTS=$(mktemp)
    # shellcheck disable=SC2064
    trap "rm -f $XPC_ENTITLEMENTS" EXIT

    cat > "$XPC_ENTITLEMENTS" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>
</dict>
</plist>
EOF

    # Sign Sparkle Installer Launcher
    if [ -d "$APP_PATH/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Installer.xpc" ]; then
        echo -e "   ${YELLOW}→${NC} Signing Sparkle Installer.xpc"
        codesign --force --sign "$SIGNING_IDENTITY" \
            --entitlements "$XPC_ENTITLEMENTS" \
            --options runtime \
            --timestamp \
            "$APP_PATH/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/Installer.xpc"
    fi

    if [ -d "$APP_PATH/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/InstallerLauncher.xpc" ]; then
        echo -e "   ${YELLOW}→${NC} Signing Sparkle InstallerLauncher.xpc"
        codesign --force --sign "$SIGNING_IDENTITY" \
            --entitlements "$XPC_ENTITLEMENTS" \
            --options runtime \
            --timestamp \
            "$APP_PATH/Contents/Frameworks/Sparkle.framework/Versions/B/XPCServices/InstallerLauncher.xpc"
    fi

    # Sign Sparkle framework itself
    echo -e "   ${YELLOW}→${NC} Signing Sparkle.framework"
    codesign --force --sign "$SIGNING_IDENTITY" \
        --options runtime \
        --timestamp \
        "$APP_PATH/Contents/Frameworks/Sparkle.framework"
fi

# Sign the main app bundle
echo -e "${BLUE}3. Signing main app bundle...${NC}"

SIGN_ARGS=(
    --force
    --sign "$SIGNING_IDENTITY"
    --options runtime
    --timestamp
)

if [ -n "$ENTITLEMENTS_FILE" ]; then
    SIGN_ARGS+=(--entitlements "$ENTITLEMENTS_FILE")
    echo -e "   ${YELLOW}→${NC} Using entitlements: $ENTITLEMENTS_FILE"
fi

echo -e "   ${YELLOW}→${NC} Signing $APP_PATH"
codesign "${SIGN_ARGS[@]}" "$APP_PATH"

# Verify the signature
echo ""
echo -e "${BLUE}4. Verifying code signature...${NC}"

if codesign --verify --deep --strict "$APP_PATH" 2>&1; then
    echo -e "${GREEN}✓ Code signature is valid${NC}"

    # Display signature info
    echo ""
    echo -e "${BLUE}Signature Information:${NC}"
    codesign -dvv "$APP_PATH" 2>&1 | grep -E "(Authority=|TeamIdentifier=|Format=)"

    echo ""
    echo -e "${GREEN}✅ Code signing completed successfully!${NC}"
    exit 0
else
    echo -e "${RED}✗ Code signature verification failed${NC}" >&2
    exit 1
fi
