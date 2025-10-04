#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Convert CHANGELOG.md section to HTML for appcast

set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default changelog path
CHANGELOG_PATH="$PROJECT_ROOT/CHANGELOG.md"

# Usage information
usage() {
    cat << EOF
Usage: $(basename "$0") <version> [changelog_path]

Convert a CHANGELOG.md version section to HTML

Arguments:
    version          Version to extract (e.g., 1.0.0, 2.0.0-beta.1)
    changelog_path   Optional path to CHANGELOG.md (default: CHANGELOG.md in project root)

Examples:
    $(basename "$0") 1.0.0
    $(basename "$0") 2.0.0-beta.1
    $(basename "$0") 1.0.0 docs/CHANGELOG.md
EOF
}

# Check arguments
if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Missing version argument${NC}" >&2
    echo ""
    usage
    exit 1
fi

VERSION=$1
if [ $# -ge 2 ]; then
    CHANGELOG_PATH=$2
fi

# Check if changelog exists
if [ ! -f "$CHANGELOG_PATH" ]; then
    echo -e "${RED}Error: CHANGELOG.md not found at: $CHANGELOG_PATH${NC}" >&2
    exit 1
fi

# Extract the section for this version
# Match lines between [VERSION] and the next [*] heading
CONTENT=$(awk -v version="$VERSION" '
    $0 ~ "^## \\[" version "\\]" { found=1; next }
    found && /^## \[/ { exit }
    found { print }
' "$CHANGELOG_PATH")

# If no content found, provide a fallback
if [ -z "$CONTENT" ]; then
    echo -e "${YELLOW}Warning: No changelog section found for version $VERSION${NC}" >&2
    echo "<p>Release version $VERSION. For full changelog, visit <a href=\"https://github.com/rdrkr/AeroSpaceBar/blob/main/CHANGELOG.md\">CHANGELOG.md</a>.</p>"
    exit 1
fi

# Convert markdown to HTML
# This is a simplified markdown converter focusing on common patterns
echo "$CONTENT" | while IFS= read -r line; do
    # Skip empty lines at the start
    if [ -z "$line" ]; then
        echo ""
        continue
    fi

    # Headers (### Header)
    if [[ "$line" =~ ^###[[:space:]]+(.*) ]]; then
        echo "<h3>${BASH_REMATCH[1]}</h3>"

    # Lists (- item or * item)
    elif [[ "$line" =~ ^[[:space:]]*[-*][[:space:]]+(.*) ]]; then
        item_content="${BASH_REMATCH[1]}"

        # Handle bold text **text**
        item_content=$(echo "$item_content" | sed -E 's/\*\*([^*]+)\*\*/<strong>\1<\/strong>/g')

        # Handle inline code `code`
        # shellcheck disable=SC2016
        item_content=$(echo "$item_content" | sed -E 's/`([^`]+)`/<code>\1<\/code>/g')

        # Handle links [text](url)
        item_content=$(echo "$item_content" | sed -E 's/\[([^]]+)\]\(([^)]+)\)/<a href="\2">\1<\/a>/g')

        # Start list if not already started
        if [ "${in_list:-false}" = "false" ]; then
            echo "<ul>"
            in_list=true
        fi

        echo "<li>$item_content</li>"

    # Regular text
    else
        # Close list if we were in one
        if [ "${in_list:-false}" = "true" ]; then
            echo "</ul>"
            in_list=false
        fi

        # Handle bold text **text**
        line=$(echo "$line" | sed -E 's/\*\*([^*]+)\*\*/<strong>\1<\/strong>/g')

        # Handle inline code `code`
        # shellcheck disable=SC2016
        line=$(echo "$line" | sed -E 's/`([^`]+)`/<code>\1<\/code>/g')

        # Handle links [text](url)
        line=$(echo "$line" | sed -E 's/\[([^]]+)\]\(([^)]+)\)/<a href="\2">\1<\/a>/g')

        if [ -n "$line" ]; then
            echo "<p>$line</p>"
        fi
    fi
done

# Close list if still open
if [ "${in_list:-false}" = "true" ]; then
    echo "</ul>"
fi
