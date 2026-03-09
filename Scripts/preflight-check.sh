#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Pre-release validation checks

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

# Check counters
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNED=0

# Helper functions
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    CHECKS_FAILED=$((CHECKS_FAILED + 1))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    CHECKS_WARNED=$((CHECKS_WARNED + 1))
}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Pre-Release Validation${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check 1: Git repository status
echo -e "${BLUE}1. Checking git repository status...${NC}"
cd "$PROJECT_ROOT"

if git diff-index --quiet HEAD --; then
    check_pass "Working directory is clean"
else
    CHANGES=$(git status --short | wc -l | tr -d ' ')
    check_warn "Working directory has uncommitted changes ($CHANGES files)"
fi

# Check if we're on main branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" = "main" ]; then
    check_pass "On main branch"
else
    check_warn "Not on main branch (current: $CURRENT_BRANCH)"
fi

echo ""

# Check 2: Version information
echo -e "${BLUE}2. Checking version information...${NC}"

if [ -f "Scripts/version.sh" ]; then
    VERSION=$(bash Scripts/version.sh --version 2>/dev/null || echo "")
    BUILD=$(bash Scripts/version.sh --build 2>/dev/null || echo "")

    if [ -n "$VERSION" ] && [ -n "$BUILD" ]; then
        check_pass "Version: $VERSION, Build: $BUILD"
    else
        check_fail "Could not read version information"
    fi
else
    check_fail "Scripts/version.sh not found"
fi

# Check CHANGELOG.md
if [ -f "$PROJECT_ROOT/CHANGELOG.md" ]; then
    if [ -n "$VERSION" ]; then
        if grep -q "\[${VERSION}\]" "$PROJECT_ROOT/CHANGELOG.md"; then
            check_pass "CHANGELOG.md contains entry for version $VERSION"
        else
            check_warn "CHANGELOG.md missing entry for version $VERSION"
        fi
    else
        check_warn "CHANGELOG.md check skipped (version not available)"
    fi
else
    check_warn "CHANGELOG.md not found"
fi

echo ""

# Check 3: Required tools
echo -e "${BLUE}3. Checking required development tools...${NC}"

# Check for Xcode
if xcode-select -p >/dev/null 2>&1; then
    XCODE_VERSION=$(xcodebuild -version 2>/dev/null | grep -m 1 "Xcode" || echo "Xcode (version unknown)")
    check_pass "$XCODE_VERSION"
else
    check_fail "Xcode not found or not selected"
fi

# Check for xcodebuild
if command -v xcodebuild >/dev/null 2>&1; then
    check_pass "xcodebuild available"
else
    check_fail "xcodebuild not found"
fi

# Check for GitHub CLI
if command -v gh >/dev/null 2>&1; then
    GH_VERSION=$(gh --version 2>&1 | grep -m 1 "gh version" || echo "gh (version unknown)")
    check_pass "$GH_VERSION"
else
    check_warn "GitHub CLI (gh) not found - needed for release automation"
fi

echo ""

# Check 4: Code signing
echo -e "${BLUE}4. Checking code signing configuration...${NC}"

# Check for Developer ID Application certificate
if security find-identity -v -p codesigning | grep -q "Apple Development"; then
    CERT_NAME=$(security find-identity -v -p codesigning | grep "Apple Development" | head -n 1 | sed 's/.*"\(.*\)"/\1/')
    check_pass "Developer ID Application certificate found"
    echo -e "   ${BLUE}→${NC} $CERT_NAME"
else
    check_warn "Developer ID Application certificate not found"
    echo -e "   ${YELLOW}→${NC} Needed for notarization"
fi

# Check for installer certificate (for DMG signing)
if security find-identity -v -p codesigning | grep -q "Developer ID Installer"; then
    check_pass "Developer ID Installer certificate found"
else
    check_warn "Developer ID Installer certificate not found (optional)"
fi

echo ""

# Check 5: Sparkle configuration
echo -e "${BLUE}5. Checking Sparkle update configuration...${NC}"

INFO_PLIST="$PROJECT_ROOT/AeroSpaceBar/Info.plist"
if [ -f "$INFO_PLIST" ]; then
    # Check SUFeedURL
    if /usr/libexec/PlistBuddy -c "Print SUFeedURL" "$INFO_PLIST" >/dev/null 2>&1; then
        FEED_URL=$(/usr/libexec/PlistBuddy -c "Print SUFeedURL" "$INFO_PLIST")
        check_pass "SUFeedURL configured"
        echo -e "   ${BLUE}→${NC} $FEED_URL"
    else
        check_fail "SUFeedURL not found in Info.plist"
    fi

    # Check SUPublicEDKey
    if /usr/libexec/PlistBuddy -c "Print SUPublicEDKey" "$INFO_PLIST" >/dev/null 2>&1; then
        check_pass "SUPublicEDKey configured"
    else
        check_fail "SUPublicEDKey not found in Info.plist"
    fi
else
    check_fail "Info.plist not found"
fi

echo ""

# Check 6: Environment variables and credentials
echo -e "${BLUE}6. Checking environment configuration...${NC}"

# Check for Sparkle private key (keychain first, then environment variable)
SPARKLE_KEY_FOUND=false
if security find-generic-password -l "Private key for signing Sparkle updates" -w >/dev/null 2>&1; then
    check_pass "Sparkle private key found in keychain"
    echo -e "   ${BLUE}→${NC} Label: Private key for signing Sparkle updates"
    SPARKLE_KEY_FOUND=true
elif security find-generic-password -s "sparkle-private-key" -w >/dev/null 2>&1; then
    check_pass "Sparkle private key found in keychain"
    echo -e "   ${BLUE}→${NC} Service: sparkle-private-key"
    SPARKLE_KEY_FOUND=true
elif security find-generic-password -s "SPARKLE_PRIVATE_KEY" -w >/dev/null 2>&1; then
    check_pass "Sparkle private key found in keychain"
    echo -e "   ${BLUE}→${NC} Service: SPARKLE_PRIVATE_KEY"
    SPARKLE_KEY_FOUND=true
elif [ -n "${SPARKLE_PRIVATE_KEY:-}" ]; then
    check_pass "SPARKLE_PRIVATE_KEY environment variable set"
    SPARKLE_KEY_FOUND=true
fi

if [ "$SPARKLE_KEY_FOUND" = false ]; then
    check_warn "Sparkle private key not found - updates won't be signed"
    echo -e "   ${YELLOW}→${NC} Store in keychain: Name it 'Private key for signing Sparkle updates' (Xcode will find it by label)"
    echo -e "   ${YELLOW}→${NC} Or use: security add-generic-password -s 'sparkle-private-key' -a 'sparkle' -w '<your-key>'"
    echo -e "   ${YELLOW}→${NC} Or set environment variable: export SPARKLE_PRIVATE_KEY='<your-key>'"
fi

# Check for GitHub token (keychain first, then environment variable)
GITHUB_TOKEN_FOUND=false
if security find-generic-password -s "AeroSpaceBar-github-token" -w >/dev/null 2>&1; then
    check_pass "GitHub token found in keychain"
    GITHUB_TOKEN_FOUND=true
elif security find-generic-password -s "PUBLIC_REPO_TOKEN" -w >/dev/null 2>&1; then
    check_pass "GitHub token found in keychain"
    GITHUB_TOKEN_FOUND=true
elif [ -n "${PUBLIC_REPO_TOKEN:-}" ] || [ -n "${GITHUB_TOKEN:-}" ]; then
    check_pass "GitHub token available in environment"
    GITHUB_TOKEN_FOUND=true
fi

if [ "$GITHUB_TOKEN_FOUND" = false ]; then
    check_warn "GitHub token not found - may be needed for automated releases"
    echo -e "   ${YELLOW}→${NC} Store in keychain: security add-generic-password -s 'AeroSpaceBar-github-token' -a 'github' -w '<your-token>'"
fi

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Passed:${NC}  $CHECKS_PASSED"
echo -e "${YELLOW}Warnings:${NC} $CHECKS_WARNED"
echo -e "${RED}Failed:${NC}  $CHECKS_FAILED"
echo ""

if [ $CHECKS_FAILED -gt 0 ]; then
    echo -e "${RED}❌ Pre-flight checks failed${NC}"
    echo -e "${YELLOW}Please fix the failed checks before proceeding with release${NC}"
    exit 1
else
    echo -e "${GREEN}✅ All critical checks passed!${NC}"
    if [ $CHECKS_WARNED -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Some warnings present - review before proceeding${NC}"
    fi
    exit 0
fi
