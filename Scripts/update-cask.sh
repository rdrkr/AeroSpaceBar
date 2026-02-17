#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Updates the Homebrew cask formula with the correct version and SHA-256 hash.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default homebrew-tap path
HOMEBREW_TAP_PATH_DEFAULT="$PROJECT_ROOT/../homebrew-tap"

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") <version> <zip-path> [homebrew-tap-path]

Updates the Homebrew cask formula with the correct version and SHA-256 hash.

Arguments:
    version             Release version (e.g., 1.0.1)
    zip-path            Path to the distribution ZIP file
    homebrew-tap-path   Path to homebrew-tap repo (default: ../homebrew-tap)

Environment Variables:
    HOMEBREW_TAP_PATH   Override default homebrew-tap repo path

Examples:
    $(basename "$0") 1.0.1 AeroSpaceBar-v1.0.1.zip
    $(basename "$0") 1.0.1 /path/to/AeroSpaceBar-v1.0.1.zip ../homebrew-tap
    HOMEBREW_TAP_PATH=/custom/path $(basename "$0") 1.0.1 AeroSpaceBar-v1.0.1.zip
EOF
}

# Validate arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Missing required arguments${NC}" >&2
    usage
    exit 1
fi

VERSION="$1"
ZIP_PATH="$2"
TAP_PATH="${3:-${HOMEBREW_TAP_PATH:-$HOMEBREW_TAP_PATH_DEFAULT}}"

# Convert to absolute path if relative
if [[ "$TAP_PATH" != /* ]]; then
    TAP_PATH="$PROJECT_ROOT/$TAP_PATH"
fi

if [[ "$ZIP_PATH" != /* ]]; then
    ZIP_PATH="$PROJECT_ROOT/$ZIP_PATH"
fi

CASK_FILE="$TAP_PATH/Casks/aerospacebar.rb"

# Validate inputs
if [ ! -f "$ZIP_PATH" ]; then
    echo -e "${RED}Error: ZIP file not found at $ZIP_PATH${NC}" >&2
    exit 1
fi

if [ ! -f "$CASK_FILE" ]; then
    echo -e "${RED}Error: Cask formula not found at $CASK_FILE${NC}" >&2
    echo -e "${YELLOW}  Ensure homebrew-tap repo is cloned at: $TAP_PATH${NC}" >&2
    exit 1
fi

# Compute SHA-256
echo -e "${BLUE}Computing SHA-256 of $ZIP_PATH...${NC}"
SHA256=$(shasum -a 256 "$ZIP_PATH" | awk '{print $1}')
echo -e "${GREEN}SHA-256: $SHA256${NC}"

# Update version in cask formula
echo -e "${BLUE}Updating cask formula at $CASK_FILE...${NC}"

# Replace version line
sed -i '' "s/^  version \".*\"/  version \"$VERSION\"/" "$CASK_FILE"

# Replace sha256 line
sed -i '' "s/^  sha256 \".*\"/  sha256 \"$SHA256\"/" "$CASK_FILE"

# Verify the update
UPDATED_VERSION=$(grep '  version "' "$CASK_FILE" | sed 's/.*version "\(.*\)".*/\1/')
UPDATED_SHA=$(grep '  sha256 "' "$CASK_FILE" | sed 's/.*sha256 "\(.*\)".*/\1/')

if [ "$UPDATED_VERSION" != "$VERSION" ]; then
    echo -e "${RED}Error: Version update failed. Expected $VERSION, got $UPDATED_VERSION${NC}" >&2
    exit 1
fi

if [ "$UPDATED_SHA" != "$SHA256" ]; then
    echo -e "${RED}Error: SHA-256 update failed. Expected $SHA256, got $UPDATED_SHA${NC}" >&2
    exit 1
fi

echo -e "${GREEN}✓ Cask formula updated successfully${NC}"
echo -e "  Version: ${GREEN}$VERSION${NC}"
echo -e "  SHA-256: ${GREEN}$SHA256${NC}"
