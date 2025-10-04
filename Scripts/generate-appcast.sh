#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Generate appcast.xml from GitHub releases

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

# GitHub repository info
PUBLIC_REPO="rdrkr/aerospacebar-app"

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [options]

Generate appcast.xml from GitHub releases in public repository

Options:
    --output <file>     Output file (default: stdout)
    -h, --help          Show this help message

Prerequisites:
    - GitHub CLI (gh) installed and authenticated
    - Releases must exist in $PUBLIC_REPO

Examples:
    $(basename "$0")
    $(basename "$0") --output appcast.xml
EOF
}

OUTPUT_FILE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}" >&2
            usage
            exit 1
            ;;
    esac
done

# Check for GitHub CLI
if ! command -v gh >/dev/null 2>&1; then
    echo -e "${RED}Error: GitHub CLI (gh) not found${NC}" >&2
    echo -e "${YELLOW}Install from: https://cli.github.com${NC}" >&2
    exit 1
fi

# Check gh authentication
if ! gh auth status >/dev/null 2>&1; then
    echo -e "${RED}Error: GitHub CLI not authenticated${NC}" >&2
    echo -e "${YELLOW}Run: gh auth login${NC}" >&2
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Generating Appcast${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Repository: ${GREEN}$PUBLIC_REPO${NC}"
echo ""

# Fetch releases from GitHub
echo -e "${BLUE}Fetching releases from GitHub...${NC}"

RELEASES=$(gh release list --repo "$PUBLIC_REPO" --limit 100 --json tagName,name,publishedAt,assets,body)

if [ -z "$RELEASES" ] || [ "$RELEASES" = "[]" ]; then
    echo -e "${YELLOW}⚠ No releases found in $PUBLIC_REPO${NC}"
    exit 1
fi

# Start XML output
{
    echo '<?xml version="1.0" encoding="utf-8"?>'
    echo '<!--Copyright (c) 2025 AeroSpaceBar by Ronen Druker.-->'
    echo '<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">'
    echo '    <channel>'
    echo '        <title>AeroSpaceBar Changelog</title>'
    echo '        <link>https://github.com/rdrkr/aerospacebar-app</link>'
    echo '        <description>Most recent changes with links to updates for AeroSpaceBar</description>'
    echo '        <language>en</language>'
    echo ''

    # Process each release
    echo "$RELEASES" | jq -c '.[]' | while read -r release; do
        TAG=$(echo "$release" | jq -r '.tagName')
        PUB_DATE=$(echo "$release" | jq -r '.publishedAt')
        BODY=$(echo "$release" | jq -r '.body')

        # Extract version from tag (remove 'v' prefix)
        VERSION="${TAG#v}"

        # Find ZIP asset
        ZIP_URL=$(echo "$release" | jq -r '.assets[] | select(.name | endswith(".zip")) | .url')
        ZIP_NAME=$(echo "$release" | jq -r '.assets[] | select(.name | endswith(".zip")) | .name')

        if [ -z "$ZIP_URL" ] || [ "$ZIP_URL" = "null" ]; then
            echo -e "${YELLOW}⚠ No ZIP asset found for release $TAG${NC}" >&2
            continue
        fi

        # Download ZIP to get size and signature
        TEMP_ZIP=$(mktemp)
        # shellcheck disable=SC2064
        trap "rm -f $TEMP_ZIP" EXIT

        if gh release download "$TAG" --repo "$PUBLIC_REPO" --pattern "*.zip" --output "$TEMP_ZIP" 2>/dev/null; then
            ZIP_SIZE=$(stat -f%z "$TEMP_ZIP" 2>/dev/null || stat -c%s "$TEMP_ZIP" 2>/dev/null || echo "0")

            # Try to get signature from release notes or generate placeholder
            SIGNATURE=$(echo "$BODY" | grep -o 'sparkle:edSignature="[^"]*"' | sed 's/sparkle:edSignature="//;s/"$//' || echo "")

            if [ -z "$SIGNATURE" ]; then
                # Try to sign if Sparkle tools are available
                # Get Sparkle private key from keychain or environment
                SPARKLE_KEY=""
                if SPARKLE_KEY=$(security find-generic-password -l "Private key for signing Sparkle updates" -w 2>/dev/null); then
                    :
                elif SPARKLE_KEY=$(security find-generic-password -s "sparkle-private-key" -w 2>/dev/null); then
                    :
                elif SPARKLE_KEY=$(security find-generic-password -s "SPARKLE_PRIVATE_KEY" -w 2>/dev/null); then
                    :
                elif [ -n "${SPARKLE_PRIVATE_KEY:-}" ]; then
                    SPARKLE_KEY="$SPARKLE_PRIVATE_KEY"
                fi

                # Find sign_update tool
                SIGN_UPDATE=""
                if [ -f "$PROJECT_ROOT/build/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update" ]; then
                    SIGN_UPDATE="$PROJECT_ROOT/build/SourcePackages/artifacts/sparkle/Sparkle/bin/sign_update"
                elif command -v sign_update >/dev/null 2>&1; then
                    SIGN_UPDATE=$(command -v sign_update)
                fi

                if [ -n "$SIGN_UPDATE" ] && [ -n "$SPARKLE_KEY" ]; then
                    KEY_FILE=$(mktemp)
                    echo "$SPARKLE_KEY" > "$KEY_FILE"
                    SIGNATURE=$("$SIGN_UPDATE" "$TEMP_ZIP" -f "$KEY_FILE" 2>/dev/null || echo "")
                    rm -f "$KEY_FILE"
                fi
            fi

            # Format pub date for RSS
            RFC_DATE=$(date -ju -f "%Y-%m-%dT%H:%M:%SZ" "$PUB_DATE" "+%a, %d %b %Y %H:%M:%S %z" 2>/dev/null || echo "$PUB_DATE")

            # Extract build number from version (assuming format like "1.0.0" -> build "100")
            # shellcheck disable=SC2018
            BUILD_NUMBER=$(echo "$VERSION" | tr -d '.-' | tr -d 'a-z')

            # Output item
            echo '        <item>'
            echo "            <title>Version $VERSION</title>"
            echo "            <link>https://github.com/rdrkr/aerospacebar-app/releases/tag/$TAG</link>"
            echo "            <pubDate>$RFC_DATE</pubDate>"
            echo "            <sparkle:version>$BUILD_NUMBER</sparkle:version>"
            echo "            <sparkle:shortVersionString>$VERSION</sparkle:shortVersionString>"
            echo '            <sparkle:minimumSystemVersion>15.0</sparkle:minimumSystemVersion>'
            echo '            <description>'
            echo '                <![CDATA['
            # shellcheck disable=SC2001
            echo "$BODY" | sed 's/^/                    /'
            echo '                ]]>'
            echo '            </description>'
            echo "            <enclosure"
            echo "                url=\"https://github.com/rdrkr/aerospacebar-app/releases/download/$TAG/$ZIP_NAME\""
            echo '                type="application/octet-stream"'
            if [ -n "$SIGNATURE" ]; then
                echo "                sparkle:edSignature=\"$SIGNATURE\""
            fi
            echo "                length=\"$ZIP_SIZE\" />"
            echo '        </item>'
            echo ''
        fi
    done

    echo '    </channel>'
    echo '</rss>'
} > "${OUTPUT_FILE:-/dev/stdout}"

if [ -n "$OUTPUT_FILE" ]; then
    echo -e "${GREEN}✓ Appcast generated: $OUTPUT_FILE${NC}"
fi

echo ""
echo -e "${GREEN}✅ Appcast generation completed!${NC}"
