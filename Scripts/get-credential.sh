#!/bin/bash
# Copyright (c) 2025 AeroSpaceBar by Ronen Druker.
# Helper function to retrieve credentials from keychain or environment

# Get credential from keychain or environment variable
# Usage: get_credential "service-name" "ENV_VAR_NAME" "default-value"
get_credential() {
    local SERVICE_NAME="$1"
    local ENV_VAR_NAME="$2"
    local DEFAULT="${3:-}"
    
    # Try keychain first
    if CREDENTIAL=$(security find-generic-password -s "$SERVICE_NAME" -w 2>/dev/null); then
        echo "$CREDENTIAL"
        return 0
    fi
    
    # Try environment variable
    if [ -n "${!ENV_VAR_NAME:-}" ]; then
        echo "${!ENV_VAR_NAME}"
        return 0
    fi
    
    # Return default or empty
    echo "$DEFAULT"
    return 1
}

# Export the function so scripts can use it
export -f get_credential
