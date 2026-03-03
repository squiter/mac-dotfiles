#!/usr/bin/env bash
# ~/.claude/anthropic_key.sh
# Stores Anthropic API key from 1Password in macOS Keychain

KEYCHAIN_SERVICE="claude-anthropic-api"
KEYCHAIN_ACCOUNT="api-key"

# Try to get key from keychain
CACHED_KEY=$(security find-generic-password -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" -w 2>/dev/null)

if [ -n "$CACHED_KEY" ]; then
    echo "$CACHED_KEY"
    exit 0
fi

# Not in keychain - fetch from 1Password
API_KEY=$(op read op://Employee/ibjmgobuur5oa5isledrk3oyga/credential 2>/dev/null)

if [ -z "$API_KEY" ]; then
    echo "Error: Failed to retrieve API key from 1Password" >&2
    exit 1
fi

# Store in keychain for future use
security add-generic-password -U -s "$KEYCHAIN_SERVICE" -a "$KEYCHAIN_ACCOUNT" -w "$API_KEY" 2>/dev/null

echo "$API_KEY"
