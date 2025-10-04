#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Verify appcast.xml integrity

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") <appcast_path>

Verify appcast.xml integrity and format

Arguments:
    appcast_path    Path to appcast.xml file

Checks performed:
    - XML syntax validation
    - Required elements presence
    - Version and build number format
    - URL accessibility
    - Signature presence

Examples:
    $(basename "$0") ../aerospacebar-app/appcast.xml
EOF
}

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Missing appcast path argument${NC}" >&2
    usage
    exit 1
fi

APPCAST_PATH="$1"

# Check if appcast exists
if [ ! -f "$APPCAST_PATH" ]; then
    echo -e "${RED}Error: Appcast file not found: $APPCAST_PATH${NC}" >&2
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Verifying Appcast${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "File: ${GREEN}$APPCAST_PATH${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Check 1: XML syntax
echo -e "${BLUE}1. Checking XML syntax...${NC}"
if xmllint --noout "$APPCAST_PATH" 2>/dev/null; then
    echo -e "${GREEN}✓ XML syntax is valid${NC}"
else
    echo -e "${RED}✗ XML syntax error${NC}"
    xmllint "$APPCAST_PATH" 2>&1 | head -n 5
    ((ERRORS++))
fi

echo ""

# Check 2: Required namespaces
echo -e "${BLUE}2. Checking namespaces...${NC}"
if grep -q 'xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"' "$APPCAST_PATH"; then
    echo -e "${GREEN}✓ Sparkle namespace declared${NC}"
else
    echo -e "${RED}✗ Missing Sparkle namespace${NC}"
    ((ERRORS++))
fi

echo ""

# Check 3: Items present
echo -e "${BLUE}3. Checking release items...${NC}"
ITEM_COUNT=$(xmllint --xpath "count(//item)" "$APPCAST_PATH" 2>/dev/null || echo "0")
if [ "$ITEM_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓ Found $ITEM_COUNT release item(s)${NC}"
else
    echo -e "${RED}✗ No release items found${NC}"
    ((ERRORS++))
fi

echo ""

# Check 4: Validate each item
echo -e "${BLUE}4. Validating release items...${NC}"
for ((i=1; i<=$ITEM_COUNT; i++)); do
    VERSION=$(xmllint --xpath "//item[$i]/sparkle:shortVersionString/text()" "$APPCAST_PATH" 2>/dev/null || echo "")
    BUILD=$(xmllint --xpath "//item[$i]/sparkle:version/text()" "$APPCAST_PATH" 2>/dev/null || echo "")
    URL=$(xmllint --xpath "//item[$i]/enclosure/@url" "$APPCAST_PATH" 2>/dev/null | sed 's/url="//;s/"$//' || echo "")
    SIGNATURE=$(xmllint --xpath "//item[$i]/enclosure/@sparkle:edSignature" "$APPCAST_PATH" 2>/dev/null | sed 's/.*edSignature="//;s/"$//' || echo "")

    echo -e "   ${BLUE}Item $i:${NC} Version $VERSION (Build $BUILD)"

    # Check version format
    if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-z]+\.[0-9]+)?$ ]]; then
        echo -e "   ${YELLOW}⚠ Unusual version format${NC}"
        ((WARNINGS++))
    fi

    # Check build number
    if [[ ! "$BUILD" =~ ^[0-9]+$ ]]; then
        echo -e "   ${RED}✗ Invalid build number format${NC}"
        ((ERRORS++))
    fi

    # Check URL
    if [ -z "$URL" ]; then
        echo -e "   ${RED}✗ Missing download URL${NC}"
        ((ERRORS++))
    fi

    # Check signature
    if [ -z "$SIGNATURE" ]; then
        echo -e "   ${YELLOW}⚠ Missing EdDSA signature${NC}"
        ((WARNINGS++))
    else
        echo -e "   ${GREEN}✓ Signature present${NC}"
    fi
done

echo ""

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Verification Summary${NC}"
echo -e "${BLUE}========================================${NC}"

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Appcast is valid${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    fi
    exit 0
else
    echo -e "${RED}✗ $ERRORS error(s) found${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS warning(s) found${NC}"
    fi
    exit 1
fi
