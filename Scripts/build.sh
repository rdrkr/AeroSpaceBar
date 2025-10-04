#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Build AeroSpaceBar using xcodebuild

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
XCODEPROJ="$PROJECT_ROOT/AeroSpaceBar.xcodeproj"

# Default values
CONFIGURATION="Release"
CLEAN=false

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") [options]

Build AeroSpaceBar using xcodebuild

Options:
    -c, --configuration <config>  Build configuration (Debug or Release, default: Release)
    --clean                       Clean before building
    -h, --help                    Show this help message

Examples:
    $(basename "$0")                     # Build Release configuration
    $(basename "$0") -c Debug            # Build Debug configuration
    $(basename "$0") --clean             # Clean and build Release
    $(basename "$0") --clean -c Debug    # Clean and build Debug
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--configuration)
            CONFIGURATION="$2"
            shift 2
            ;;
        --clean)
            CLEAN=true
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

# Validate configuration
if [ "$CONFIGURATION" != "Debug" ] && [ "$CONFIGURATION" != "Release" ]; then
    echo -e "${RED}Error: Configuration must be 'Debug' or 'Release'${NC}" >&2
    exit 1
fi

# Check if Xcode project exists
if [ ! -d "$XCODEPROJ" ]; then
    echo -e "${RED}Error: Xcode project not found at $XCODEPROJ${NC}" >&2
    exit 1
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Building AeroSpaceBar${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Configuration: ${GREEN}$CONFIGURATION${NC}"
echo -e "Clean build:   ${GREEN}$CLEAN${NC}"
echo ""

# Change to project root
cd "$PROJECT_ROOT"

# Clean if requested
if [ "$CLEAN" = true ]; then
    echo -e "${BLUE}Cleaning build artifacts...${NC}"
    xcodebuild -project "$XCODEPROJ" \
        -scheme AeroSpaceBar \
        -configuration "$CONFIGURATION" \
        -derivedDataPath "$PROJECT_ROOT/build" \
        clean
    echo -e "${GREEN}✓ Clean complete${NC}"
    echo ""
fi

# Build
echo -e "${BLUE}Building AeroSpaceBar ($CONFIGURATION)...${NC}"
xcodebuild -project "$XCODEPROJ" \
    -scheme AeroSpaceBar \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$PROJECT_ROOT/build" \
    build

BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Build successful${NC}"
    
    # Determine build output path
    if [ "$CONFIGURATION" = "Release" ]; then
        APP_PATH="$PROJECT_ROOT/build/Build/Products/Release/AeroSpaceBar.app"
    else
        APP_PATH="$PROJECT_ROOT/build/Build/Products/Debug/AeroSpaceBar.app"
    fi
    
    if [ -d "$APP_PATH" ]; then
        echo -e "${GREEN}App bundle: $APP_PATH${NC}"
    else
        echo -e "${YELLOW}⚠ App bundle not found at expected path: $APP_PATH${NC}"
    fi
    
    exit 0
else
    echo ""
    echo -e "${RED}✗ Build failed${NC}"
    exit 1
fi
