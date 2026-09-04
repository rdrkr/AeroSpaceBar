#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Bump version and build number in Xcode project

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
XCODEPROJ="$PROJECT_ROOT/AeroSpaceBar.xcodeproj/project.pbxproj"

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") <version> [build_number]

Bump version and build number in Xcode project settings

Arguments:
    version         New version string (e.g., 1.0.0, 2.0.0-beta.1)
    build_number    Optional build number. If not provided, will auto-increment

Examples:
    $(basename "$0") 1.0.0              # Bump to 1.0.0, auto-increment build
    $(basename "$0") 2.0.0 200          # Set version 2.0.0, build 200
    $(basename "$0") 2.1.0-beta.1       # Bump to beta release
    $(basename "$0") 2.1.0-rc.1         # Bump to release candidate

Supported pre-release formats:
    - beta: 1.0.0-beta.1
    - alpha: 1.0.0-alpha.1
    - rc: 1.0.0-rc.1
EOF
}

# Validate version format
validate_version() {
    local version=$1
    # Matches: X.Y.Z or X.Y.Z-beta.N or X.Y.Z-alpha.N or X.Y.Z-rc.N
    if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-((beta|alpha|rc)\.[0-9]+))?$ ]]; then
        echo -e "${RED}Error: Invalid version format: $version${NC}" >&2
        echo -e "${YELLOW}Expected format: X.Y.Z or X.Y.Z-beta.N or X.Y.Z-alpha.N or X.Y.Z-rc.N${NC}" >&2
        return 1
    fi
    return 0
}

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Missing version argument${NC}" >&2
    echo ""
    usage
    exit 1
fi

NEW_VERSION=$1
BUILD_NUMBER=${2:-}

# Validate version format
if ! validate_version "$NEW_VERSION"; then
    exit 1
fi

# Check if Xcode project exists
if [ ! -f "$XCODEPROJ" ]; then
    echo -e "${RED}Error: Xcode project file not found at $XCODEPROJ${NC}" >&2
    exit 1
fi

# Get current version and build from Xcode project
CURRENT_VERSION=$(bash "$SCRIPT_DIR/version.sh" --version 2>/dev/null || echo "unknown")
CURRENT_BUILD=$(bash "$SCRIPT_DIR/version.sh" --build 2>/dev/null || echo "0")

# Highest build number that has already been released, read from the tags rather
# than the working tree.
#
# The working tree alone is not a safe basis: v1.0.0-beta.14 was tagged from a
# commit that never landed on the release branch, so the tree stayed on build 13
# and the next release reused build 14. Sparkle compares CFBundleVersion, so a
# duplicate build makes the update invisible to everyone already on it.
highest_released_build() {
    local highest=0 tag tag_build tmp
    tmp=$(mktemp)

    for tag in $(git tag -l 'v*' 2>/dev/null); do
        if ! git show "$tag:AeroSpaceBar.xcodeproj/project.pbxproj" >"$tmp" 2>/dev/null; then
            continue
        fi

        # Same extraction as version.sh: the main app target's build number.
        tag_build=$(grep -B 50 "PRODUCT_BUNDLE_IDENTIFIER = com.rdrkr.AeroSpaceBar;" "$tmp" \
            | grep "CURRENT_PROJECT_VERSION" | head -n 1 \
            | sed 's/.*CURRENT_PROJECT_VERSION = \(.*\);/\1/' | tr -d ' ;')

        if [[ "$tag_build" =~ ^[0-9]+$ ]] && [ "$tag_build" -gt "$highest" ]; then
            highest=$tag_build
        fi
    done

    rm -f "$tmp"
    echo "$highest"
}

# Auto-increment build number if not provided
if [ -z "$BUILD_NUMBER" ]; then
    RELEASED_BUILD=$(highest_released_build)
    BASE_BUILD=$CURRENT_BUILD

    if [ "$RELEASED_BUILD" -gt "$BASE_BUILD" ]; then
        echo -e "${YELLOW}Working tree is at build $CURRENT_BUILD but build $RELEASED_BUILD is already released${NC}"
        BASE_BUILD=$RELEASED_BUILD
    fi

    BUILD_NUMBER=$((BASE_BUILD + 1))
    echo -e "${BLUE}Auto-incrementing build number: $BASE_BUILD → $BUILD_NUMBER${NC}"
fi

# Validate build number
if [[ ! "$BUILD_NUMBER" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: Build number must be a positive integer: $BUILD_NUMBER${NC}" >&2
    exit 1
fi

# Detect if this is a pre-release
IS_PRERELEASE=false
if [[ "$NEW_VERSION" =~ -(beta|alpha|rc)\. ]]; then
    IS_PRERELEASE=true
fi

# Display summary
echo -e "${GREEN}Version Update Summary:${NC}"
echo -e "  Current: ${YELLOW}$CURRENT_VERSION${NC} (${YELLOW}$CURRENT_BUILD${NC})"
echo -e "  New:     ${GREEN}$NEW_VERSION${NC} (${GREEN}$BUILD_NUMBER${NC})"
if [ "$IS_PRERELEASE" = true ]; then
    echo -e "  Type:    ${BLUE}Pre-release${NC}"
else
    echo -e "  Type:    ${GREEN}Stable${NC}"
fi

# Update Xcode project build settings
echo ""
echo -e "${BLUE}Updating Xcode project build settings...${NC}"

# Backup project file
cp "$XCODEPROJ" "$XCODEPROJ.backup"

# Update MARKETING_VERSION for main app target
# This updates all occurrences in the main AeroSpaceBar target configurations
sed -i '' "s/MARKETING_VERSION = [^;]*;/MARKETING_VERSION = $NEW_VERSION;/g" "$XCODEPROJ"

# Update CURRENT_PROJECT_VERSION for main app target
# Only update the ones that match the pattern for the main target
sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $BUILD_NUMBER;/g" "$XCODEPROJ"

# Verify at least one change was made
if diff "$XCODEPROJ.backup" "$XCODEPROJ" >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠ No changes detected in Xcode project${NC}"
    rm "$XCODEPROJ.backup"
    exit 1
else
    echo -e "${GREEN}✓ Successfully updated Xcode project${NC}"
    echo -e "  MARKETING_VERSION: ${GREEN}$NEW_VERSION${NC}"
    echo -e "  CURRENT_PROJECT_VERSION: ${GREEN}$BUILD_NUMBER${NC}"
    rm "$XCODEPROJ.backup"
fi

# Suggest next steps
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Review the changes:"
echo -e "     ${BLUE}git diff AeroSpaceBar.xcodeproj/project.pbxproj${NC}"
echo -e "  2. Update CHANGELOG.md with release notes"
echo -e "  3. Commit the version bump:"
echo -e "     ${BLUE}git add AeroSpaceBar.xcodeproj/project.pbxproj CHANGELOG.md${NC}"
echo -e "     ${BLUE}git commit -m \"chore :: bump version to $NEW_VERSION ($BUILD_NUMBER)\"${NC}"
echo -e "  4. Create and push a tag:"
echo -e "     ${BLUE}git tag -a v$NEW_VERSION -m \"Release $NEW_VERSION\"${NC}"
echo -e "     ${BLUE}git push origin v$NEW_VERSION${NC}"
echo -e "  5. Or run the release script:"
echo -e "     ${BLUE}./Scripts/release.sh${NC}"
