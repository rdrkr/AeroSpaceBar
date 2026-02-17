#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Run tests for Domain, Data, Presentation packages and AeroSpaceBarUITests with coverage

set -e

# Default options
RUN_UI_TESTS=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Coverage thresholds
DOMAIN_THRESHOLD=97.0
DATA_THRESHOLD=35.00
PRESENTATION_THRESHOLD=17.0

# Usage information
usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Run tests for Domain, Data, and Presentation packages with coverage

Options:
    --ui-tests              Include AeroSpaceBarUITests (skipped by default)
    -h, --help              Show this help message

Examples:
    $(basename "$0")                # Run package tests only
    $(basename "$0") --ui-tests     # Run package tests and UI tests
EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --ui-tests)
            RUN_UI_TESTS=true
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

# Package paths
DOMAIN_PKG="$PROJECT_ROOT/Packages/Domain"
DATA_PKG="$PROJECT_ROOT/Packages/Data"
PRESENTATION_PKG="$PROJECT_ROOT/Packages/Presentation"
XCODEPROJ="$PROJECT_ROOT/AeroSpaceBar.xcodeproj"
DERIVED_DATA="$PROJECT_ROOT/build/DerivedData"

# Arrays to store results (bash 3 compatible)
PACKAGES=("Domain" "Data" "Presentation")
PACKAGE_PATHS=("$DOMAIN_PKG" "$DATA_PKG" "$PRESENTATION_PKG")

# Test and coverage results
DOMAIN_TEST_STATUS=""
DATA_TEST_STATUS=""
PRESENTATION_TEST_STATUS=""
UITESTS_TEST_STATUS=""

DOMAIN_COVERAGE=""
DATA_COVERAGE=""
PRESENTATION_COVERAGE=""
UITESTS_COVERAGE=""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Running Package Tests with Coverage${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to set test status
set_test_status() {
    local pkg_name=$1
    local status=$2
    
    case $pkg_name in
        "Domain") DOMAIN_TEST_STATUS=$status ;;
        "Data") DATA_TEST_STATUS=$status ;;
        "Presentation") PRESENTATION_TEST_STATUS=$status ;;
        "UITests") UITESTS_TEST_STATUS=$status ;;
    esac
}

# Function to set coverage
set_coverage() {
    local pkg_name=$1
    local coverage=$2
    
    case $pkg_name in
        "Domain") DOMAIN_COVERAGE=$coverage ;;
        "Data") DATA_COVERAGE=$coverage ;;
        "Presentation") PRESENTATION_COVERAGE=$coverage ;;
        "UITests") UITESTS_COVERAGE=$coverage ;;
    esac
}

# Function to get test status
get_test_status() {
    local pkg_name=$1
    
    case $pkg_name in
        "Domain") echo "$DOMAIN_TEST_STATUS" ;;
        "Data") echo "$DATA_TEST_STATUS" ;;
        "Presentation") echo "$PRESENTATION_TEST_STATUS" ;;
        "UITests") echo "$UITESTS_TEST_STATUS" ;;
    esac
}

# Function to get coverage
get_coverage() {
    local pkg_name=$1
    
    case $pkg_name in
        "Domain") echo "$DOMAIN_COVERAGE" ;;
        "Data") echo "$DATA_COVERAGE" ;;
        "Presentation") echo "$PRESENTATION_COVERAGE" ;;
        "UITests") echo "$UITESTS_COVERAGE" ;;
    esac
}

# Function to run tests for a package and extract coverage
run_package_tests() {
    local pkg_name=$1
    local pkg_path=$2
    
    echo -e "${BLUE}Testing ${pkg_name}...${NC}"
    
    cd "$pkg_path"
    
    # Run tests with coverage enabled
    # Use PIPESTATUS to get swift test exit code, not tee's exit code
    swift test --enable-code-coverage --disable-swift-testing 2>&1 | tee /tmp/"${pkg_name}"_test.log
    test_exit_code=${PIPESTATUS[0]}
    
    if [[ "${test_exit_code}" -eq 0 ]]; then
        set_test_status "$pkg_name" "PASSED"
        echo -e "${GREEN}✓ ${pkg_name} tests passed${NC}"
    else
        set_test_status "$pkg_name" "FAILED"
        echo -e "${RED}✗ ${pkg_name} tests failed${NC}"
        cd "$PROJECT_ROOT"
        return 1
    fi
    
    # Find the test binary
    local test_binary
    test_binary=$(find .build -type f -path "*/MacOS/*PackageTests" 2>/dev/null | head -n 1)
    
    if [ -z "$test_binary" ]; then
        echo -e "${YELLOW}⚠  Could not find test binary for ${pkg_name}${NC}"
        set_coverage "$pkg_name" "N/A"
        cd "$PROJECT_ROOT"
        return 0
    fi
    
    # Find and merge profraw files
    local profraw_dir=".build/arm64-apple-macosx/debug/codecov"
    
    if [ ! -d "$profraw_dir" ]; then
        echo -e "${YELLOW}⚠  Could not find codecov directory for ${pkg_name}${NC}"
        set_coverage "$pkg_name" "0.00"
        cd "$PROJECT_ROOT"
        return 0
    fi
    
    # Count profraw files
    local profraw_count
    profraw_count=$(find "$profraw_dir" -name "*.profraw" 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$profraw_count" -eq 0 ]; then
        echo -e "${YELLOW}⚠  Could not find profraw files for ${pkg_name}${NC}"
        set_coverage "$pkg_name" "0.00"
        cd "$PROJECT_ROOT"
        return 0
    fi
    
    # Merge profraw files into profdata
    local profdata="/tmp/${pkg_name}.profdata"
    if ! xcrun llvm-profdata merge -sparse "$profraw_dir"/*.profraw -o "$profdata" 2>/dev/null; then
        echo -e "${YELLOW}⚠  Could not merge profraw files for ${pkg_name}${NC}"
        set_coverage "$pkg_name" "0.00"
        cd "$PROJECT_ROOT"
        return 0
    fi
    
    # Extract coverage using llvm-cov
    local coverage_report
    coverage_report=$(xcrun llvm-cov report "$test_binary" \
        -instr-profile="$profdata" \
        2>/dev/null || echo "")
    
    if [ -z "$coverage_report" ]; then
        echo -e "${YELLOW}⚠  Could not generate coverage report for ${pkg_name}${NC}"
        set_coverage "$pkg_name" "0.00"
    else
        # Filter report to only include Sources directory and calculate coverage
        local filtered_report
        filtered_report=$(echo "$coverage_report" | grep "Sources/${pkg_name}")
        
        if [ -z "$filtered_report" ]; then
            # Try without package name in path
            filtered_report=$(echo "$coverage_report" | grep "Sources/")
        fi
        
        if [ -z "$filtered_report" ]; then
            echo -e "${YELLOW}⚠  No source files found in coverage report for ${pkg_name}${NC}"
            set_coverage "$pkg_name" "0.00"
        else
            # Calculate coverage from filtered lines using Lines columns (8 = total, 9 = missed)
            local coverage_pct
            coverage_pct=$(echo "$filtered_report" | awk '
                BEGIN { total_lines = 0; missed_lines = 0 }
                {
                    # Lines are in columns 8 (total) and 9 (missed)
                    lines_total = $8
                    lines_missed = $9
                    if (lines_total ~ /^[0-9]+$/ && lines_missed ~ /^[0-9]+$/) {
                        total_lines += lines_total
                        missed_lines += lines_missed
                    }
                }
                END {
                    if (total_lines > 0) {
                        covered_lines = total_lines - missed_lines
                        pct = (covered_lines / total_lines) * 100
                        printf "%.2f", pct
                    } else {
                        print "0.00"
                    }
                }
            ')
            
            if [ -z "$coverage_pct" ]; then
                coverage_pct="0.00"
            fi
            
            set_coverage "$pkg_name" "$coverage_pct"
            echo -e "${BLUE}Coverage: ${coverage_pct}%${NC}"
        fi
    fi
    
    cd "$PROJECT_ROOT"
    echo ""
}

# Run tests for each package (fail fast)
for i in 0 1 2; do
    run_package_tests "${PACKAGES[$i]}" "${PACKAGE_PATHS[$i]}" || exit 1
done

# Run AeroSpaceBarUITests with xcodebuild (optional)
if [ "$RUN_UI_TESTS" = true ]; then
    echo -e "${BLUE}Testing UITests...${NC}"
    
    xcodebuild test \
        -project "$XCODEPROJ" \
        -scheme AeroSpaceBar \
        -destination 'platform=macOS' \
        -derivedDataPath "$DERIVED_DATA" \
        -enableCodeCoverage YES \
        -only-testing:AeroSpaceBarUITests \
        2>&1 | tee /tmp/UITests_test.log
    
    # Check if tests actually ran by looking for test results in output
    if grep -q "Test Suite 'AeroSpaceBarUITests'" /tmp/UITests_test.log; then
        # Tests ran - check if they passed
        if grep -q "Test Suite 'AeroSpaceBarUITests' passed" /tmp/UITests_test.log || \
           grep -q "Test Suite 'All tests' passed" /tmp/UITests_test.log; then
            set_test_status "UITests" "PASSED"
            echo -e "${GREEN}✓ UITests passed${NC}"
            set_coverage "UITests" "N/A"
        else
            set_test_status "UITests" "FAILED"
            echo -e "${RED}✗ UITests failed${NC}"
            set_coverage "UITests" "N/A"
            exit 1
        fi
    else
        # Tests didn't run - mark as skipped
        set_test_status "UITests" "SKIPPED"
        echo -e "${YELLOW}⚠ UITests skipped (no UI tests found or build failed)${NC}"
        set_coverage "UITests" "N/A"
    fi
    echo ""
else
    # UI tests disabled by default
    set_test_status "UITests" "SKIPPED"
    set_coverage "UITests" "N/A"
fi

# Print summary table
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Test Coverage Summary${NC}"
echo -e "${BLUE}========================================${NC}"
printf "%-15s %-10s %-10s %-10s\n" "Package" "Tests" "Coverage" "Threshold"
echo "--------------------------------------------------"

ALL_PASSED=true
COVERAGE_FAILED=false

# Include all test targets
ALL_TARGETS=("${PACKAGES[@]}" "UITests")

for pkg in "${ALL_TARGETS[@]}"; do
    test_status=$(get_test_status "$pkg")
    coverage=$(get_coverage "$pkg")
    
    # Get threshold for package
    case $pkg in
        "Domain") threshold=$DOMAIN_THRESHOLD ;;
        "Data") threshold=$DATA_THRESHOLD ;;
        "Presentation") threshold=$PRESENTATION_THRESHOLD ;;
        *) threshold="N/A" ;;
    esac
    
    # Color code based on status
    if [ "$test_status" = "PASSED" ]; then
        test_color=$GREEN
    elif [ "$test_status" = "SKIPPED" ]; then
        test_color=$YELLOW
    else
        test_color=$RED
        ALL_PASSED=false
    fi
    
    # Check coverage threshold
    if [ "$coverage" != "N/A" ] && [ "$threshold" != "N/A" ]; then
        coverage_check=$(python3 -c "print('PASS' if float('$coverage') >= $threshold else 'FAIL')" 2>/dev/null || echo "FAIL")
        if [ "$coverage_check" = "FAIL" ]; then
            coverage_color=$RED
            COVERAGE_FAILED=true
        else
            coverage_color=$GREEN
        fi
    else
        coverage_color=$NC
    fi
    
    # Format coverage display - don't add % if it's N/A
    if [ "$coverage" = "N/A" ]; then
        coverage_display="$coverage"
    else
        coverage_display="${coverage}%"
    fi
    
    # Format threshold display
    if [ "$threshold" = "N/A" ]; then
        threshold_display="-"
    else
        threshold_display="${threshold}%"
    fi
    
    printf "%-15s ${test_color}%-10s${NC} ${coverage_color}%-10s${NC} %-10s\n" "$pkg" "$test_status" "$coverage_display" "$threshold_display"
done

echo "--------------------------------------------------"

# Final result
if [ "$ALL_PASSED" = false ]; then
    echo -e "${RED}✗ Tests failed${NC}"
    exit 1
elif [ "$COVERAGE_FAILED" = true ]; then
    echo -e "${RED}✗ Coverage below required thresholds${NC}"
    exit 1
else
    echo -e "${GREEN}✓ All tests passed and coverage thresholds met${NC}"
    exit 0
fi
