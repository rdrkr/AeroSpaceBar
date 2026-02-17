#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Complete automated release workflow

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

# Convert PUBLIC_REPO_PATH to absolute path
PUBLIC_REPO_PATH_DEFAULT="$PROJECT_ROOT/../aerospacebar-app"
PUBLIC_REPO_PATH="${PUBLIC_REPO_PATH:-$PUBLIC_REPO_PATH_DEFAULT}"

# Convert to absolute path if relative
if [[ "$PUBLIC_REPO_PATH" != /* ]]; then
    PUBLIC_REPO_PATH="$PROJECT_ROOT/$PUBLIC_REPO_PATH"
fi

# Convert HOMEBREW_TAP_PATH to absolute path
HOMEBREW_TAP_PATH_DEFAULT="$PROJECT_ROOT/../homebrew-tap"
HOMEBREW_TAP_PATH="${HOMEBREW_TAP_PATH:-$HOMEBREW_TAP_PATH_DEFAULT}"

# Convert to absolute path if relative
if [[ "$HOMEBREW_TAP_PATH" != /* ]]; then
    HOMEBREW_TAP_PATH="$PROJECT_ROOT/$HOMEBREW_TAP_PATH"
fi

PUBLIC_REPO="rdrkr/aerospacebar-app"
HOMEBREW_TAP_REPO="rdrkr/homebrew-tap"

# Options
SKIP_BUILD=false
SKIP_NOTARIZE=false
CREATE_DMG=false
VERSION_ARG=""

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [options]

Complete automated release workflow for AeroSpaceBar

Options:
    --version <ver>   Version to release (e.g., 1.0.1) - will bump version before release
    --skip-build      Skip building the app
    --skip-notarize   Skip Apple notarization
    --dmg             Create DMG instead of ZIP (ZIP is default)
    -h, --help        Show this help message

Environment Variables:
    PUBLIC_REPO_PATH      Path to public repo (default: ../aerospacebar-app)
    HOMEBREW_TAP_PATH     Path to homebrew-tap repo (default: ../homebrew-tap)
    PUBLIC_REPO_TOKEN     GitHub token for pushing to public repo
    SPARKLE_PRIVATE_KEY   Sparkle private key for signing updates

Examples:
    $(basename "$0")                        # Release current version with ZIP (default)
    $(basename "$0") --version 1.0.1        # Bump to 1.0.1 and release
    $(basename "$0") --skip-notarize        # Skip notarization (for testing)
    $(basename "$0") --dmg                  # Create DMG instead of ZIP
    $(basename "$0") --version 1.0.1 --dmg  # Bump version and create DMG
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            VERSION_ARG="$2"
            shift 2
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        --skip-notarize)
            SKIP_NOTARIZE=true
            shift
            ;;
        --dmg)
            CREATE_DMG=true
            shift
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

echo -e "${BOLD}${BLUE}========================================${NC}"
echo -e "${BOLD}${BLUE}AeroSpaceBar Automated Release${NC}"
echo -e "${BOLD}${BLUE}========================================${NC}"
echo ""

# Ensure public repo is cloned
echo -e "${BLUE}Checking public repository...${NC}"
if [ ! -d "$PUBLIC_REPO_PATH" ]; then
    echo -e "${YELLOW}Public repo not found at: $PUBLIC_REPO_PATH${NC}"
    echo -e "${BLUE}Cloning public repository...${NC}"

    PARENT_DIR="$(dirname "$PUBLIC_REPO_PATH")"
    mkdir -p "$PARENT_DIR"

    if git clone "https://github.com/${PUBLIC_REPO}.git" "$PUBLIC_REPO_PATH"; then
        echo -e "${GREEN}✓ Public repo cloned to: $PUBLIC_REPO_PATH${NC}"
    else
        echo -e "${RED}✗ Failed to clone public repository${NC}"
        echo -e "${YELLOW}Please clone manually: git clone https://github.com/${PUBLIC_REPO}.git $PUBLIC_REPO_PATH${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Public repo found at: $PUBLIC_REPO_PATH${NC}"

    # Pull latest changes
    echo -e "${BLUE}Pulling latest changes from public repo...${NC}"
    cd "$PUBLIC_REPO_PATH"
    if git pull origin main; then
        echo -e "${GREEN}✓ Public repo updated${NC}"
    else
        echo -e "${YELLOW}⚠ Failed to pull latest changes (continuing anyway)${NC}"
    fi
    cd "$PROJECT_ROOT"
fi
echo ""

# Ensure homebrew-tap repo is cloned
echo -e "${BLUE}Checking homebrew-tap repository...${NC}"
if [ ! -d "$HOMEBREW_TAP_PATH" ]; then
    echo -e "${YELLOW}Homebrew-tap repo not found at: $HOMEBREW_TAP_PATH${NC}"
    echo -e "${BLUE}Cloning homebrew-tap repository...${NC}"

    PARENT_DIR="$(dirname "$HOMEBREW_TAP_PATH")"
    mkdir -p "$PARENT_DIR"

    if git clone "https://github.com/${HOMEBREW_TAP_REPO}.git" "$HOMEBREW_TAP_PATH"; then
        echo -e "${GREEN}✓ Homebrew-tap repo cloned to: $HOMEBREW_TAP_PATH${NC}"
    else
        echo -e "${YELLOW}⚠ Failed to clone homebrew-tap repository (cask update will be skipped)${NC}"
    fi
else
    echo -e "${GREEN}✓ Homebrew-tap repo found at: $HOMEBREW_TAP_PATH${NC}"

    # Pull latest changes
    echo -e "${BLUE}Pulling latest changes from homebrew-tap repo...${NC}"
    cd "$HOMEBREW_TAP_PATH"
    if git pull origin main; then
        echo -e "${GREEN}✓ Homebrew-tap repo updated${NC}"
    else
        echo -e "${YELLOW}⚠ Failed to pull latest changes (continuing anyway)${NC}"
    fi
    cd "$PROJECT_ROOT"
fi
echo ""

# Step 1: Bump version and update changelog if specified
if [ -n "$VERSION_ARG" ]; then
    echo -e "${BLUE}Step 1a: Bumping version to $VERSION_ARG...${NC}"
    if ! bash "$SCRIPT_DIR/bump-version.sh" "$VERSION_ARG"; then
        echo -e "${RED}✗ Version bump failed${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Version bumped to $VERSION_ARG${NC}"

    # Generate changelog entry
    echo -e "${BLUE}Step 1b: Updating changelog...${NC}"

    # Check if version already exists in CHANGELOG
    if grep -q "## \[${VERSION_ARG}\]" "$PROJECT_ROOT/CHANGELOG.md"; then
        echo -e "${YELLOW}⚠ Version ${VERSION_ARG} already exists in CHANGELOG.md, skipping generation${NC}"
        CHANGELOG_UPDATED=true
    else
        # Version doesn't exist, generate it
        LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
        TEMP_CHANGELOG=$(mktemp)

        if [ -n "$LAST_TAG" ]; then
            # Generate changelog from commits since last tag
            echo -e "${BLUE}Generating changelog from commits since $LAST_TAG...${NC}"
            if bash "$SCRIPT_DIR/generate-changelog.sh" --version "$VERSION_ARG" "$LAST_TAG" HEAD --output "$TEMP_CHANGELOG"; then
                echo -e "${GREEN}✓ Changelog generated from commits since $LAST_TAG${NC}"
            else
                echo -e "${RED}✗ Failed to generate changelog from commits${NC}"
                rm -f "$TEMP_CHANGELOG"
                exit 1
            fi
        else
            # First release - generate from beginning of repo
            echo -e "${YELLOW}⚠ No previous tag found - generating from beginning of repository${NC}"
            FIRST_COMMIT=$(git rev-list --max-parents=0 HEAD)
            if bash "$SCRIPT_DIR/generate-changelog.sh" --version "$VERSION_ARG" "$FIRST_COMMIT" HEAD --output "$TEMP_CHANGELOG"; then
                echo -e "${GREEN}✓ Changelog generated from repository history${NC}"
            else
                echo -e "${RED}✗ Failed to generate changelog${NC}"
                rm -f "$TEMP_CHANGELOG"
                exit 1
            fi
        fi

        CHANGELOG_UPDATED=false
    fi

    # Update CHANGELOG.md file (only if not already updated)
    if [ "$CHANGELOG_UPDATED" = false ] && [ -f "$PROJECT_ROOT/CHANGELOG.md" ]; then
        # Create backup
        cp "$PROJECT_ROOT/CHANGELOG.md" "$PROJECT_ROOT/CHANGELOG.md.backup"

        # Find the line number of [Unreleased] section
        UNRELEASED_LINE=$(grep -n "^## \[Unreleased\]" "$PROJECT_ROOT/CHANGELOG.md" | head -1 | cut -d: -f1 || echo "")

        if [ -n "$UNRELEASED_LINE" ]; then
            # Find the next version section line (relative to after Unreleased section)
            NEXT_VERSION_LINE=$(tail -n +$((UNRELEASED_LINE + 1)) "$PROJECT_ROOT/CHANGELOG.md" | grep -n "^## \[" | head -1 | cut -d: -f1 || echo "")

            if [ -n "$NEXT_VERSION_LINE" ]; then
                # Insert before next version section
                INSERT_LINE=$((UNRELEASED_LINE + NEXT_VERSION_LINE))

                # Insert new changelog entry before next version
                head -n $((INSERT_LINE - 1)) "$PROJECT_ROOT/CHANGELOG.md.backup" > "$PROJECT_ROOT/CHANGELOG.md"
                # shellcheck disable=SC2129
                echo "" >> "$PROJECT_ROOT/CHANGELOG.md"
                cat "$TEMP_CHANGELOG" >> "$PROJECT_ROOT/CHANGELOG.md"
                echo "" >> "$PROJECT_ROOT/CHANGELOG.md"
                tail -n +$INSERT_LINE "$PROJECT_ROOT/CHANGELOG.md.backup" >> "$PROJECT_ROOT/CHANGELOG.md"
            else
                # No next version, append at end of file
                # Find last line of Unreleased section content (skip empty lines at end)
                LAST_CONTENT_LINE=$(grep -n "^### " "$PROJECT_ROOT/CHANGELOG.md" | tail -1 | cut -d: -f1 || echo "")

                if [ -z "$LAST_CONTENT_LINE" ]; then
                    LAST_CONTENT_LINE=$UNRELEASED_LINE
                fi

                # Read until after Unreleased section, add new entry, then add rest
                # shellcheck disable=SC2086
                head -n $LAST_CONTENT_LINE "$PROJECT_ROOT/CHANGELOG.md.backup" > "$PROJECT_ROOT/CHANGELOG.md"

                # Add spacing and new entry
                # shellcheck disable=SC2129
                echo "" >> "$PROJECT_ROOT/CHANGELOG.md"
                echo "" >> "$PROJECT_ROOT/CHANGELOG.md"
                cat "$TEMP_CHANGELOG" >> "$PROJECT_ROOT/CHANGELOG.md"

                # Add remaining content if any
                TOTAL_LINES=$(wc -l < "$PROJECT_ROOT/CHANGELOG.md.backup" | tr -d ' ')
                if [ "$LAST_CONTENT_LINE" -lt "$TOTAL_LINES" ]; then
                    tail -n +$((LAST_CONTENT_LINE + 1)) "$PROJECT_ROOT/CHANGELOG.md.backup" >> "$PROJECT_ROOT/CHANGELOG.md"
                fi
            fi

            echo -e "${GREEN}✓ CHANGELOG.md updated${NC}"
        else
            echo -e "${YELLOW}⚠ No [Unreleased] section found, appending to end${NC}"
            echo "" >> "$PROJECT_ROOT/CHANGELOG.md"
            cat "$TEMP_CHANGELOG" >> "$PROJECT_ROOT/CHANGELOG.md"
            echo -e "${GREEN}✓ CHANGELOG.md updated${NC}"
        fi

        rm "$PROJECT_ROOT/CHANGELOG.md.backup"
        rm -f "$TEMP_CHANGELOG"
        CHANGELOG_UPDATED=true
    fi

    # Commit version and changelog changes (locally only, will push at end)
    echo -e "${BLUE}Step 1c: Committing version and changelog changes...${NC}"

    # Verify CHANGELOG.md has the new version
    if ! grep -q "## \[${VERSION_ARG}\]" "$PROJECT_ROOT/CHANGELOG.md"; then
        echo -e "${RED}✗ CHANGELOG.md does not contain entry for version ${VERSION_ARG}${NC}"
        exit 1
    fi

    git add "$PROJECT_ROOT/AeroSpaceBar.xcodeproj/project.pbxproj" "$PROJECT_ROOT/CHANGELOG.md"

    # Check if there are changes to commit
    if git diff --staged --quiet; then
        echo -e "${YELLOW}⚠ No changes to commit${NC}"
        VERSION_COMMITTED=false
    else
        git commit -m "chore :: bump version to $VERSION_ARG"
        echo -e "${GREEN}✓ Changes committed locally (will push after successful release)${NC}"
        VERSION_COMMITTED=true
    fi
    echo ""
else
    VERSION_COMMITTED=false
fi

# Step 2: Pre-flight checks
echo -e "${BLUE}Step 2: Running pre-flight checks...${NC}"
if ! bash "$SCRIPT_DIR/preflight-check.sh"; then
    echo -e "${RED}✗ Pre-flight checks failed${NC}"
    exit 1
fi
echo ""

# Step 3: Get version information
echo -e "${BLUE}Step 3: Getting version information...${NC}"
VERSION=$(bash "$SCRIPT_DIR/version.sh" --version)
BUILD=$(bash "$SCRIPT_DIR/version.sh" --build)
echo -e "Version: ${GREEN}$VERSION${NC} (Build ${GREEN}$BUILD${NC})"
echo ""

# Step 4: Build the app
if [ "$SKIP_BUILD" = false ]; then
    echo -e "${BLUE}Step 4: Building AeroSpaceBar...${NC}"
    if ! bash "$SCRIPT_DIR/build.sh" --clean; then
        echo -e "${RED}✗ Build failed${NC}"
        exit 1
    fi
    echo ""
else
    echo -e "${YELLOW}Step 4: Skipping build (--skip-build)${NC}"
    echo ""
fi

# Determine app path
APP_PATH="$PROJECT_ROOT/build/Build/Products/Release/AeroSpaceBar.app"
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}Error: App bundle not found at $APP_PATH${NC}"
    exit 1
fi

# Step 5: Code sign and notarize
if [ "$SKIP_NOTARIZE" = false ]; then
    echo -e "${BLUE}Step 5: Signing and notarizing for distribution...${NC}"
    if ! bash "$SCRIPT_DIR/sign-and-notarize.sh" "$APP_PATH"; then
        echo -e "${RED}✗ Code signing/notarization failed${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ App signed and notarized${NC}"
else
    echo -e "${BLUE}Step 5: Signing for development (notarization skipped)...${NC}"
    if bash "$SCRIPT_DIR/codesign-app.sh" "$APP_PATH"; then
        echo -e "${GREEN}✓ App signed with Developer ID${NC}"
    else
        echo -e "${RED}✗ Signing with Developer ID failed${NC}"
        exit 1
    fi
fi

# Step 6: Create distribution package (ZIP or DMG)
DISTRIBUTION_PATH=""

if [ "$CREATE_DMG" = true ]; then
    echo -e "${BLUE}Step 6a: Creating DMG...${NC}"
    DISTRIBUTION_PATH="$PROJECT_ROOT/AeroSpaceBar-v${VERSION}.dmg"
    if ! bash "$SCRIPT_DIR/create-dmg.sh" "$APP_PATH" "$DISTRIBUTION_PATH"; then
        echo -e "${RED}✗ DMG creation failed${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}Step 6a: Creating ZIP archive...${NC}"
    DISTRIBUTION_PATH="$PROJECT_ROOT/AeroSpaceBar-v${VERSION}.zip"
    cd "$PROJECT_ROOT/build/Build/Products/Release"
    ditto -c -k --keepParent "AeroSpaceBar.app" "$DISTRIBUTION_PATH"
fi

# Sign and notarize
if [ "$SKIP_NOTARIZE" = false ]; then
    echo -e "${BLUE}Step 6b: Signing and notarizing for distribution...${NC}"
    if ! bash "$SCRIPT_DIR/sign-and-notarize.sh" "$DISTRIBUTION_PATH"; then
        echo -e "${RED}✗ Code signing/notarization failed${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ DMG signed and notarized${NC}"
else
    echo -e "${BLUE}Step 6c: Signing for development (notarization skipped)...${NC}"
    if bash "$SCRIPT_DIR/codesign-app.sh" "$DISTRIBUTION_PATH"; then
        echo -e "${GREEN}✓ DMG signed with Developer ID${NC}"
    else
        echo -e "${RED}✗ Signing with Developer ID failed${NC}"
        exit 1
    fi
fi
echo -e "${GREEN}✓ Distribution created and signed: $DISTRIBUTION_PATH${NC}"
echo ""

# Step 7: Create GitHub release
echo -e "${BLUE}Step 7: Creating GitHub release...${NC}"

# Check if tag exists
if git rev-parse "v$VERSION" >/dev/null 2>&1; then
    echo -e "${YELLOW}Step 7a: ⚠ Tag v$VERSION already exists${NC}"
else
    echo -e "${BLUE}Step 7a: Creating tag v$VERSION...${NC}"
    git tag -a "v$VERSION" -m "Release $VERSION"
    git push origin "v$VERSION"
fi

# Generate release notes from CHANGELOG
RELEASE_NOTES=$(bash "$SCRIPT_DIR/changelog-to-html.sh" "$VERSION" 2>/dev/null || echo "Release $VERSION")

# Create GitHub release in public repo
echo -e "${BLUE}Step 7b: Creating GitHub release in $PUBLIC_REPO...${NC}"

# Get GitHub token from keychain or environment
PUBLIC_GH_REPO_TOKEN=""
if PUBLIC_GH_REPO_TOKEN=$(security find-generic-password -s "aerospacebar-app-github-token" -w 2>/dev/null); then
    :
elif PUBLIC_GH_REPO_TOKEN=$(security find-generic-password -s "PUBLIC_REPO_TOKEN" -w 2>/dev/null); then
    :
elif [ -n "${PUBLIC_REPO_TOKEN:-}" ]; then
    PUBLIC_GH_REPO_TOKEN="$PUBLIC_REPO_TOKEN"
fi

RELEASE_ARGS=(
    "v$VERSION"
    --repo "$PUBLIC_REPO"
    --title "v$VERSION"
    --notes "$RELEASE_NOTES"
)

# Add distribution file (ZIP or DMG)
if [ -n "$DISTRIBUTION_PATH" ] && [ -f "$DISTRIBUTION_PATH" ]; then
    RELEASE_ARGS+=("$DISTRIBUTION_PATH")
fi

if gh release create "${RELEASE_ARGS[@]}"; then
    echo -e "${GREEN}✓ GitHub release created${NC}"
else
    echo -e "${RED}✗ Failed to create GitHub release${NC}"
    exit 1
fi

echo ""

# Step 8: Update appcast
echo -e "${BLUE}Step 8: Updating appcast.xml...${NC}"

# Check if public repo is available
if [ -d "$PUBLIC_REPO_PATH" ]; then
    APPCAST_PATH="$PUBLIC_REPO_PATH/appcast.xml"

    if bash "$SCRIPT_DIR/update-appcast.sh" "$VERSION" "$BUILD" "$DISTRIBUTION_PATH" "$APPCAST_PATH"; then
        echo -e "${GREEN}✓ Appcast updated and ZIP signed${NC}"

        # Create tag in public repo
        echo -e "${BLUE}Step 8a: Creating tag v$VERSION in public repo...${NC}"
        cd "$PUBLIC_REPO_PATH"

        # Check if tag already exists
        if git rev-parse "v$VERSION" >/dev/null 2>&1; then
            echo -e "${YELLOW}⚠ Tag v$VERSION already exists in public repo${NC}"
        else
            git tag -a "v$VERSION" -m "Release $VERSION"
            echo -e "${GREEN}✓ Tag v$VERSION created in public repo${NC}"
        fi

        # Commit appcast changes (will push at end)
        echo -e "${BLUE}Step 8b: Committing appcast changes...${NC}"
        git add appcast.xml

        # Check if there are changes to commit
        if git diff --staged --quiet; then
            echo -e "${YELLOW}⚠ No changes to commit in appcast${NC}"
            APPCAST_COMMITTED=false
        else
            git commit -m "Update appcast for v$VERSION"
            echo -e "${GREEN}✓ Appcast changes committed locally (will push after all operations succeed)${NC}"
            APPCAST_COMMITTED=true
        fi

        # Return to project root
        cd "$PROJECT_ROOT"
    else
        echo -e "${RED}✗ Failed to update appcast${NC}"
        exit 1
    fi
else
    echo -e "${RED}✗ Public repo not found at $PUBLIC_REPO_PATH${NC}"
    echo -e "${YELLOW}  Clone it with: git clone https://github.com/$PUBLIC_REPO.git $PUBLIC_REPO_PATH${NC}"
    exit 1
fi
echo ""

# Step 8c: Update Homebrew cask formula
CASK_COMMITTED=false
if [ -d "$HOMEBREW_TAP_PATH" ] && [ -f "$HOMEBREW_TAP_PATH/Casks/aerospacebar.rb" ]; then
    echo -e "${BLUE}Step 8c: Updating Homebrew cask formula...${NC}"

    if bash "$SCRIPT_DIR/update-cask.sh" "$VERSION" "$DISTRIBUTION_PATH" "$HOMEBREW_TAP_PATH"; then
        echo -e "${GREEN}✓ Cask formula updated${NC}"

        # Commit cask changes
        cd "$HOMEBREW_TAP_PATH"
        git add Casks/aerospacebar.rb

        if git diff --staged --quiet; then
            echo -e "${YELLOW}⚠ No changes to commit in cask formula${NC}"
        else
            git commit -m "Update AeroSpaceBar to v$VERSION"
            echo -e "${GREEN}✓ Cask changes committed locally (will push after all operations succeed)${NC}"
            CASK_COMMITTED=true
        fi

        cd "$PROJECT_ROOT"
    else
        echo -e "${YELLOW}⚠ Failed to update cask formula (continuing anyway)${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Homebrew-tap repo not found, skipping cask update${NC}"
fi
echo ""

# Step 9: Push all changes to repositories
echo -e "${BLUE}Step 9: Pushing all changes to repositories...${NC}"

# Push version bump commit to private repo
if [ "$VERSION_COMMITTED" = true ]; then
    echo -e "${BLUE}Step 9a: Pushing version bump to private repo...${NC}"
    if git push origin "$(git branch --show-current)"; then
        echo -e "${GREEN}✓ Version bump pushed to private repo${NC}"
    else
        echo -e "${RED}✗ Failed to push version bump to private repo${NC}"
        exit 1
    fi

    # Push tag to private repo
    if git rev-parse "v$VERSION" >/dev/null 2>&1; then
        if git push origin "v$VERSION" 2>/dev/null; then
            echo -e "${GREEN}✓ Tag v$VERSION pushed to private repo${NC}"
        else
            echo -e "${YELLOW}⚠ Tag v$VERSION already exists in private repo${NC}"
        fi
    fi
fi

# Push appcast and tag to public repo
if [ "${APPCAST_COMMITTED:-false}" = true ] || [ -n "${DISTRIBUTION_PATH:-}" ]; then
    echo -e "${BLUE}Step 9b: Pushing changes to public repo...${NC}"
    cd "$PUBLIC_REPO_PATH"

    REMOTE_URL="https://${PUBLIC_GH_REPO_TOKEN}@github.com/${PUBLIC_REPO}.git"

    # Push main branch
    if [ "${APPCAST_COMMITTED:-false}" = true ]; then
        if [ "$REMOTE_URL" = "origin" ]; then
            git push
        else
            git push "$REMOTE_URL" main
        fi
        echo -e "${GREEN}✓ Appcast pushed to public repo${NC}"
    fi

    # Push tag
    if git rev-parse "v$VERSION" >/dev/null 2>&1; then
        if ! git ls-remote --tags "$REMOTE_URL" "v$VERSION" | grep -q "v$VERSION"; then
            if [ "$REMOTE_URL" = "origin" ]; then
                git push origin "v$VERSION"
            else
                git push "$REMOTE_URL" "v$VERSION"
            fi
            echo -e "${GREEN}✓ Tag v$VERSION pushed to public repo${NC}"
        else
            echo -e "${YELLOW}⚠ Tag v$VERSION already exists in public repo${NC}"
        fi
    fi

    cd "$PROJECT_ROOT"
fi

# Push cask changes to homebrew-tap repo
if [ "$CASK_COMMITTED" = true ]; then
    echo -e "${BLUE}Step 9c: Pushing changes to homebrew-tap repo...${NC}"
    cd "$HOMEBREW_TAP_PATH"

    HOMEBREW_REMOTE_URL="https://${PUBLIC_GH_REPO_TOKEN}@github.com/${HOMEBREW_TAP_REPO}.git"

    if git push "$HOMEBREW_REMOTE_URL" main; then
        echo -e "${GREEN}✓ Cask formula pushed to homebrew-tap${NC}"
    else
        echo -e "${RED}✗ Failed to push cask changes to homebrew-tap${NC}"
        echo -e "${YELLOW}  You may need to push manually: cd $HOMEBREW_TAP_PATH && git push origin main${NC}"
        exit 1
    fi

    cd "$PROJECT_ROOT"
fi

echo ""

# Summary
echo -e "${BOLD}${GREEN}========================================${NC}"
echo -e "${BOLD}${GREEN}Release Complete!${NC}"
echo -e "${BOLD}${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}Version:${NC} $VERSION"
echo -e "${GREEN}Release URL:${NC} https://github.com/$PUBLIC_REPO/releases/tag/v$VERSION"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Verify the release at: ${BLUE}https://github.com/$PUBLIC_REPO/releases/tag/v$VERSION${NC}"
echo -e "  2. Test the update from within the app"
echo -e "  3. Monitor Sparkle update feed: ${BLUE}$PUBLIC_REPO_PATH/appcast.xml${NC}"
echo ""
