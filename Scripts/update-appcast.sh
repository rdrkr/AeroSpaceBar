#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Update appcast.xml with new release

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

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") <version> <build_number> <zip_path> <appcast_path>

Update appcast.xml with a new release entry

Arguments:
    version         Version number (e.g., 1.0.0)
    build_number    Build number (e.g., 100)
    zip_path        Path to the release DISTRIBUTION file
    appcast_path    Path to appcast.xml file

Prerequisites:
    - DISTRIBUTION file must exist and be signed
    - SPARKLE_PRIVATE_KEY environment variable (for signing)

Examples:
    $(basename "$0") 1.0.0 100 AeroSpaceBar-v1.0.0.zip appcast.xml
EOF
}

# Check arguments
if [ $# -lt 4 ]; then
    echo -e "${RED}Error: Missing required arguments${NC}" >&2
    usage
    exit 1
fi

VERSION="$1"
BUILD_NUMBER="$2"
DISTRIBUTION_PATH="$3"
APPCAST_PATH="$4"

# Check if DISTRIBUTION exists
if [ ! -f "$DISTRIBUTION_PATH" ]; then
    echo -e "${RED}Error: DISTRIBUTION file not found: $DISTRIBUTION_PATH${NC}" >&2
    exit 1
fi

# Get DISTRIBUTION size
DISTRIBUTION_SIZE=$(stat -f%z "$DISTRIBUTION_PATH" 2>/dev/null || stat -c%s "$DISTRIBUTION_PATH" 2>/dev/null || echo "0")
DISTRIBUTION_NAME=$(basename "$DISTRIBUTION_PATH")

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Updating Appcast${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Version:      ${GREEN}$VERSION${NC}"
echo -e "Build Number: ${GREEN}$BUILD_NUMBER${NC}"
echo -e "DISTRIBUTION: ${GREEN}$DISTRIBUTION_PATH${NC}"
echo -e "Size:         ${GREEN}$DISTRIBUTION_SIZE bytes${NC}"
echo -e "Appcast:      ${GREEN}$APPCAST_PATH${NC}"
echo ""

# Generate EdDSA signature
echo -e "${BLUE}1. Generating EdDSA signature...${NC}"

# Get Sparkle private key from keychain or environment
SPARKLE_KEY=""
if SPARKLE_KEY=$(security find-generic-password -l "Private key for signing Sparkle updates" -w 2>/dev/null); then
    echo -e "${BLUE}Using Sparkle key from keychain (label: Private key for signing Sparkle updates)${NC}"
elif SPARKLE_KEY=$(security find-generic-password -s "sparkle-private-key" -w 2>/dev/null); then
    echo -e "${BLUE}Using Sparkle key from keychain (service: sparkle-private-key)${NC}"
elif SPARKLE_KEY=$(security find-generic-password -s "SPARKLE_PRIVATE_KEY" -w 2>/dev/null); then
    echo -e "${BLUE}Using Sparkle key from keychain (service: SPARKLE_PRIVATE_KEY)${NC}"
elif [ -n "${SPARKLE_PRIVATE_KEY:-}" ]; then
    SPARKLE_KEY="$SPARKLE_PRIVATE_KEY"
    echo -e "${BLUE}Using Sparkle key from environment${NC}"
fi

SIGNATURE=""
if [ -z "$SPARKLE_KEY" ]; then
  echo -e "${YELLOW}⚠ Sparkle private key not found - signature not generated${NC}"
  echo -e "${YELLOW}  Store in keychain: Name it 'Private key for signing Sparkle updates' (Xcode will find it by label)${NC}"
  echo -e "${YELLOW}  Or use: security add-generic-password -s 'sparkle-private-key' -a 'sparkle' -w '<your-key>'${NC}"
  exit 1
fi

# Create temporary key file
KEY_FILE=$(mktemp)
# shellcheck disable=SC2064
trap "rm -f $KEY_FILE" EXIT
echo "$SPARKLE_KEY" > "$KEY_FILE"

# Find sign_update tool (check build artifacts first)
SIGN_UPDATE=""
if [ -f "$PROJECT_ROOT/build/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update" ]; then
    SIGN_UPDATE="$PROJECT_ROOT/build/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update"
elif command -v sign_update >/dev/null 2>&1; then
    SIGN_UPDATE=$(command -v sign_update)
fi

# Sign with Sparkle tools
if [ -z "$SIGN_UPDATE" ]; then
  echo -e "${YELLOW}⚠ sign_update not found in build artifacts or PATH${NC}"
  echo -e "${YELLOW}  Expected: $PROJECT_ROOT/build/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update${NC}"
  exit 1
fi

SIGNATURE=$("$SIGN_UPDATE" "$DISTRIBUTION_PATH" -f "$KEY_FILE" 2>/dev/null || echo "")
if [ -n "$SIGNATURE" ]; then
    echo -e "${GREEN}✓ Signature generated${NC}"
else
    echo -e "${YELLOW}⚠ Failed to generate signature${NC}"
    exit 1
fi

# Get current date in RFC 2822 format
PUB_DATE=$(date -R)

# Get release notes from CHANGELOG
echo ""
echo -e "${BLUE}2. Extracting release notes...${NC}"

RELEASE_NOTES=""
if [ -f "$PROJECT_ROOT/CHANGELOG.md" ] && [ -f "$SCRIPT_DIR/changelog-to-html.sh" ]; then
    RELEASE_NOTES=$(bash "$SCRIPT_DIR/changelog-to-html.sh" "$VERSION" 2>/dev/null || echo "<p>Release version $VERSION</p>")
    echo -e "${GREEN}✓ Release notes extracted${NC}"
else
    RELEASE_NOTES="<p>Release version $VERSION</p>"
    echo -e "${YELLOW}⚠ Using default release notes${NC}"
fi

# Create new item entry
echo ""
echo -e "${BLUE}3. Creating appcast entry...${NC}"

# Build enclosure tag with or without signature
ENCLOSURE_TAG="            <enclosure
            url=\"https://github.com/rdrkr/AeroSpaceBar/releases/download/v$VERSION/$DISTRIBUTION_NAME\"
            type=\"application/octet-stream\"
            $SIGNATURE />"

NEW_ITEM=$(cat <<EOF
        <item>
            <title>Version $VERSION</title>
            <link>https://github.com/rdrkr/AeroSpaceBar/releases/tag/v$VERSION</link>
            <pubDate>$PUB_DATE</pubDate>
            <sparkle:version>$BUILD_NUMBER</sparkle:version>
            <sparkle:shortVersionString>$VERSION</sparkle:shortVersionString>
            <sparkle:minimumSystemVersion>15.0</sparkle:minimumSystemVersion>
            <description>
                <![CDATA[
                    $RELEASE_NOTES
                ]]>
            </description>
$ENCLOSURE_TAG
        </item>

EOF
)

# Update appcast.xml
if [ -f "$APPCAST_PATH" ]; then
    # Backup existing appcast
    cp "$APPCAST_PATH" "$APPCAST_PATH.backup"
    echo -e "${GREEN}✓ Backed up existing appcast${NC}"

    # Create temp file with new item
    TEMP_ITEM_FILE=$(mktemp)
    # shellcheck disable=SC2064
    trap "rm -f $TEMP_ITEM_FILE" EXIT
    echo "$NEW_ITEM" > "$TEMP_ITEM_FILE"

    # Insert new item after <language>en</language> line using sed
    sed -e '/<language>en<\/language>/r '"$TEMP_ITEM_FILE" "$APPCAST_PATH.backup" > "$APPCAST_PATH"
    rm -f "$TEMP_ITEM_FILE"

    echo -e "${GREEN}✓ Appcast updated${NC}"
else
    echo -e "${YELLOW}Creating new appcast file...${NC}"

    cat > "$APPCAST_PATH" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<!--Copyright (c) 2025 AeroSpaceBar by Ronen Druker.-->
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title>AeroSpaceBar Changelog</title>
        <link>https://github.com/rdrkr/AeroSpaceBar</link>
        <description>Most recent changes with links to updates for AeroSpaceBar</description>
        <language>en</language>

$NEW_ITEM
    </channel>
</rss>
EOF

    echo -e "${GREEN}✓ New appcast created${NC}"
fi

echo ""
echo -e "${GREEN}✅ Appcast updated successfully!${NC}"
echo -e "${BLUE}Review the changes:${NC} git diff $APPCAST_PATH"
