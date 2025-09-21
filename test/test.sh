#!/bin/bash

# Simple test runner for bash functions

set -e

# Set plugin_dir
plugin_dir="$(pwd)"

# Source utils
. ./lib/utils.bash

echo "Running tests..."

# Test list_servers
echo "Test: list_servers"
output=$(list_servers)
if echo "$output" | grep -q "claude-server" && echo "$output" | grep -q "mcp-core" && echo "$output" | grep -q "local-llm" && echo "$output" | grep -q "custom-mcp"; then
  echo "PASS"
else
  echo "FAIL: list_servers output incorrect"
  exit 1
fi

# Test install_server unknown
echo "Test: install_server unknown"
output=$(install_server "unknown" "1.0.0" "/tmp/test" 2>&1 || true)
if echo "$output" | grep -q "Unknown server type"; then
  echo "PASS"
else
  echo "FAIL: install_server did not fail for unknown"
  exit 1
fi

# Test get_install_path
echo "Test: get_install_path"
# Mock asdf current
asdf() {
  echo "mcp latest"
}
output=$(get_install_path "claude-server")
expected="$HOME/.asdf/installs/mcp/latest/servers/claude-server"
if [ "$output" = "$expected" ]; then
  echo "PASS"
else
  echo "FAIL: get_install_path incorrect: got $output, expected $expected"
  exit 1
fi

# Test validate_claude_version latest
echo "Test: validate_claude_version latest"
validate_claude_version "latest"
echo "PASS"

# Test validate_claude_version invalid (mock npm)
echo "Test: validate_claude_version invalid"
npm() {
  return 1
}
output=$(validate_claude_version "invalid" 2>&1 || true)
if echo "$output" | grep -q "not found"; then
  echo "PASS"
else
  echo "FAIL: validate_claude_version did not fail for invalid"
  exit 1
fi

# Test check_status
echo "Test: check_status"
output=$(check_status)
if echo "$output" | grep -q "Checking status"; then
  echo "PASS"
else
  echo "FAIL: check_status output incorrect"
  exit 1
fi

# Note: For functions requiring external commands, mocks are needed.
# For full coverage, add stubs for node, npm, claude in real tests.

echo "All tests passed!"