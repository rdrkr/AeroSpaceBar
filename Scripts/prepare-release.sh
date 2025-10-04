#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Interactive release preparation script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Project paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [version]

Interactive script to prepare a new release

Arguments:
    version     Optional version number (e.g., 1.0.0, 2.0.0-beta.1)
                If not provided, will prompt interactively

Examples:
    $(basename "$0")              # Interactive mode
    $(basename "$0") 1.0.0        # Prepare version 1.0.0
    $(basename "$0") 2.0.0-beta.1 # Prepare beta release
EOF
}

# Get version argument or prompt
NEW_VERSION="${1:-}"

echo -e "${BOLD}${BLUE}========================================${NC}"
echo -e "${BOLD}${BLUE}AeroSpaceBar Release Preparation${NC}"
echo -e "${BOLD}${BLUE}========================================${NC}"
echo ""

# Step 1: Check git status
echo -e "${BLUE}Step 1: Checking git repository status...${NC}"
cd "$PROJECT_ROOT"

if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠ Working directory has uncommitted changes:${NC}"
    git status --short
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Aborting.${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Working directory is clean${NC}"
fi

echo ""

# Step 2: Get current version
echo -e "${BLUE}Step 2: Checking current version...${NC}"
CURRENT_VERSION=$(bash "$SCRIPT_DIR/version.sh" --version 2>/dev/null || echo "unknown")
CURRENT_BUILD=$(bash "$SCRIPT_DIR/version.sh" --build 2>/dev/null || echo "0")

echo -e "Current version: ${GREEN}$CURRENT_VERSION${NC} (Build ${GREEN}$CURRENT_BUILD${NC})"
echo ""

# Step 3: Get new version
if [ -z "$NEW_VERSION" ]; then
    echo -e "${BLUE}Step 3: Enter new version...${NC}"
    echo -e "${YELLOW}Formats:${NC}"
    echo -e "  - Stable: 1.0.0, 2.0.0, 2.1.0"
    echo -e "  - Beta: 1.0.0-beta.1, 2.0.0-beta.2"
    echo -e "  - Alpha: 1.0.0-alpha.1"
    echo -e "  - RC: 2.0.0-rc.1"
    echo ""
    # shellcheck disable=SC2162
    read -p "New version: " NEW_VERSION

    if [ -z "$NEW_VERSION" ]; then
        echo -e "${RED}Error: Version cannot be empty${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}New version will be: ${GREEN}$NEW_VERSION${NC}"
echo ""

# Step 4: Verify CHANGELOG
echo -e "${BLUE}Step 4: Checking CHANGELOG.md...${NC}"

if [ ! -f "$PROJECT_ROOT/CHANGELOG.md" ]; then
    echo -e "${RED}✗ CHANGELOG.md not found${NC}"
    exit 1
fi

if grep -q "\[${NEW_VERSION}\]" "$PROJECT_ROOT/CHANGELOG.md"; then
    echo -e "${GREEN}✓ CHANGELOG.md contains entry for version $NEW_VERSION${NC}"
else
    echo -e "${YELLOW}⚠ CHANGELOG.md does not contain entry for version $NEW_VERSION${NC}"
    echo ""
    read -p "Open CHANGELOG.md for editing? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        ${EDITOR:-vi} "$PROJECT_ROOT/CHANGELOG.md"
    fi

    if ! grep -q "\[${NEW_VERSION}\]" "$PROJECT_ROOT/CHANGELOG.md"; then
        echo -e "${RED}✗ CHANGELOG.md still missing entry for $NEW_VERSION${NC}"
        echo -e "${YELLOW}Please add the release notes and run this script again${NC}"
        exit 1
    fi
fi

echo ""

# Step 5: Bump version
echo -e "${BLUE}Step 5: Bumping version...${NC}"

if bash "$SCRIPT_DIR/bump-version.sh" "$NEW_VERSION"; then
    echo -e "${GREEN}✓ Version bumped successfully${NC}"
else
    echo -e "${RED}✗ Failed to bump version${NC}"
    exit 1
fi

echo ""

# Step 6: Run pre-flight checks
echo -e "${BLUE}Step 6: Running pre-flight checks...${NC}"

if bash "$SCRIPT_DIR/preflight-check.sh"; then
    echo -e "${GREEN}✓ Pre-flight checks passed${NC}"
else
    echo -e "${YELLOW}⚠ Some pre-flight checks failed or warned${NC}"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Aborting. Fix the issues and run again.${NC}"
        exit 1
    fi
fi

echo ""

# Step 7: Review and commit
echo -e "${BLUE}Step 7: Review changes...${NC}"
echo ""
git diff AeroSpaceBar.xcodeproj/project.pbxproj
echo ""

read -p "Commit these changes? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    git add AeroSpaceBar.xcodeproj/project.pbxproj CHANGELOG.md
    git commit -m "chore :: bump version to $NEW_VERSION"
    echo -e "${GREEN}✓ Changes committed${NC}"
else
    echo -e "${YELLOW}Changes not committed${NC}"
fi

echo ""

# Step 8: Next steps
echo -e "${BOLD}${GREEN}========================================${NC}"
echo -e "${BOLD}${GREEN}Release Preparation Complete!${NC}"
echo -e "${BOLD}${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo ""
echo -e "  ${BOLD}Option A: Manual Release${NC}"
echo -e "    1. Push changes: ${BLUE}git push origin main${NC}"
echo -e "    2. Create tag: ${BLUE}git tag -a v$NEW_VERSION -m \"Release $NEW_VERSION\"${NC}"
echo -e "    3. Push tag: ${BLUE}git push origin v$NEW_VERSION${NC}"
echo -e "    4. Run release script: ${BLUE}./Scripts/release.sh${NC}"
echo ""
echo -e "  ${BOLD}Option B: Automated Release${NC}"
echo -e "    1. Run release script: ${BLUE}./Scripts/release.sh${NC}"
echo -e "       (Will create tag and release automatically)"
echo ""
