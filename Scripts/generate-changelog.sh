#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Generate CHANGELOG.md entry from git commits

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
Usage: $(basename "$0") [options] <from_ref> [to_ref]

Generate CHANGELOG.md entry from git commits between two references

Arguments:
    from_ref        Starting git reference (tag, branch, commit)
    to_ref          Ending git reference (default: HEAD)

Options:
    --version <ver> Version number for the changelog entry (e.g., 1.0.1)
    --output <file> Output file (default: stdout)
    -h, --help      Show this help message

Examples:
    $(basename "$0") v1.0.0 HEAD --version 1.0.1
    $(basename "$0") v1.0.0 --version 1.0.1 --output CHANGELOG_NEW.md
    $(basename "$0") --version 1.0.1 v1.0.0 v1.0.1

Commit message conventions:
    feat :: <description>     New feature
    fix :: <description>      Bug fix
    docs :: <description>     Documentation changes
    chore :: <description>    Build/tooling changes
    refactor :: <description> Code refactoring
    test :: <description>     Test changes
    perf :: <description>     Performance improvements
    security :: <description> Security improvements

Example commits:
    feat :: added dark mode support
    fix :: resolved memory leak in icon cache
    docs :: updated README with new installation steps
EOF
}

VERSION=""
OUTPUT_FILE=""
FROM_REF=""
TO_REF="HEAD"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            VERSION="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
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
            if [ -z "$FROM_REF" ]; then
                FROM_REF="$1"
            else
                TO_REF="$1"
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [ -z "$FROM_REF" ]; then
    echo -e "${RED}Error: Missing FROM_REF argument${NC}" >&2
    usage
    exit 1
fi

if [ -z "$VERSION" ]; then
    echo -e "${RED}Error: --version is required${NC}" >&2
    usage
    exit 1
fi

# Verify git references exist
if ! git rev-parse "$FROM_REF" >/dev/null 2>&1; then
    echo -e "${RED}Error: Invalid git reference: $FROM_REF${NC}" >&2
    exit 1
fi

if ! git rev-parse "$TO_REF" >/dev/null 2>&1; then
    echo -e "${RED}Error: Invalid git reference: $TO_REF${NC}" >&2
    exit 1
fi

echo -e "${BLUE}========================================${NC}" >&2
echo -e "${BLUE}Generating Changelog${NC}" >&2
echo -e "${BLUE}========================================${NC}" >&2
echo -e "Version:   ${GREEN}$VERSION${NC}" >&2
echo -e "From:      ${GREEN}$FROM_REF${NC}" >&2
echo -e "To:        ${GREEN}$TO_REF${NC}" >&2
echo "" >&2

# Get current date
RELEASE_DATE=$(date +"%Y-%m-%d")

# Categorize commits
declare -A COMMITS
COMMITS[Added]=""
COMMITS[Changed]=""
COMMITS[Fixed]=""
COMMITS[Security]=""
COMMITS[Performance]=""
COMMITS[Documentation]=""
COMMITS[Other]=""

# Parse git log
while IFS= read -r commit; do
    # Skip empty lines
    [ -z "$commit" ] && continue

    # Parse commit message
    if [[ "$commit" =~ ^feat\ ::\ (.+)$ ]]; then
        COMMITS[Added]+="- ${BASH_REMATCH[1]}\n"
    elif [[ "$commit" =~ ^fix\ ::\ (.+)$ ]]; then
        COMMITS[Fixed]+="- ${BASH_REMATCH[1]}\n"
    elif [[ "$commit" =~ ^security\ ::\ (.+)$ ]]; then
        COMMITS[Security]+="- ${BASH_REMATCH[1]}\n"
    elif [[ "$commit" =~ ^perf\ ::\ (.+)$ ]]; then
        COMMITS[Performance]+="- ${BASH_REMATCH[1]}\n"
    elif [[ "$commit" =~ ^docs\ ::\ (.+)$ ]]; then
        COMMITS[Documentation]+="- ${BASH_REMATCH[1]}\n"
    elif [[ "$commit" =~ ^(refactor|chore|test|improv|remove)\ ::\ (.+)$ ]]; then
        COMMITS[Changed]+="- ${BASH_REMATCH[2]}\n"
    else
        # Skip merge commits and version bumps
        if [[ ! "$commit" =~ ^Merge ]] && \
           [[ ! "$commit" =~ ^(chore|bump).*version ]] && \
           [[ ! "$commit" =~ ^v[0-9] ]]; then
            COMMITS[Other]+="- $commit\n"
        fi
    fi
done < <(git log --pretty=format:"%s" "$FROM_REF..$TO_REF")

# Generate changelog
{
    echo "## [$VERSION] - $RELEASE_DATE"
    echo ""

    # Added
    if [ -n "${COMMITS[Added]}" ]; then
        echo "### Added"
        echo ""
        echo -e "${COMMITS[Added]}"
    fi

    # Changed
    if [ -n "${COMMITS[Changed]}" ]; then
        echo "### Changed"
        echo ""
        echo -e "${COMMITS[Changed]}"
    fi

    # Fixed
    if [ -n "${COMMITS[Fixed]}" ]; then
        echo "### Fixed"
        echo ""
        echo -e "${COMMITS[Fixed]}"
    fi

    # Performance
    if [ -n "${COMMITS[Performance]}" ]; then
        echo "### Performance"
        echo ""
        echo -e "${COMMITS[Performance]}"
    fi

    # Security
    if [ -n "${COMMITS[Security]}" ]; then
        echo "### Security"
        echo ""
        echo -e "${COMMITS[Security]}"
    fi

    # Documentation
    if [ -n "${COMMITS[Documentation]}" ]; then
        echo "### Documentation"
        echo ""
        echo -e "${COMMITS[Documentation]}"
    fi

    # Other
    if [ -n "${COMMITS[Other]}" ]; then
        echo "### Other"
        echo ""
        echo -e "${COMMITS[Other]}"
    fi

} > "${OUTPUT_FILE:-/dev/stdout}"

if [ -n "$OUTPUT_FILE" ]; then
    echo -e "${GREEN}✓ Changelog generated: $OUTPUT_FILE${NC}" >&2
fi

echo "" >&2
echo -e "${GREEN}✅ Changelog generation completed!${NC}" >&2
echo -e "${YELLOW}Next steps:${NC}" >&2
echo -e "  1. Review the generated changelog" >&2
echo -e "  2. Edit and refine the entries as needed" >&2
echo -e "  3. Insert into CHANGELOG.md after the [Unreleased] section" >&2
