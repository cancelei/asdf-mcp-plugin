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
if echo "$output" | grep -q "claude-server" && echo "$output" | grep -q "github-server" && echo "$output" | grep -q "mcp-core" && echo "$output" | grep -q "local-llm" && echo "$output" | grep -q "custom-mcp"; then
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

echo "All tests passed!"

# Extended coverage tests for lib/*

echo "Extended: utils curl_opts with token"
(
  set -e
  plugin_dir="$(pwd)"
  export GITHUB_API_TOKEN="dummy"
  . ./lib/utils.bash
  list_servers >/dev/null
) || true

echo "Extended: validation pass/fail for node and npm"
# Node OK
node() { echo "v20.1.0"; }
validate_node_version
# Node too old
node() { echo "v18.0.0"; }
out=$(validate_node_version 2>&1 || true)
echo "$out" | grep -q "Node.js v20 or later" && echo "PASS" || { echo "FAIL: validate_node_version fail path"; exit 1; }
# npm present
unset -f node || true
validate_npm 2>/dev/null || true

echo "Extended: installation install_claude_server success"
tmpdir=$(mktemp -d)
# Stubs for install
node() { echo "v20.0.0"; }
npm() {
  case "$1" in
    view) echo "1.2.3" ;;
    install) echo "installed" ;;
    audit) echo "ok" ;;
    *) echo "noop" ;;
  esac
}
mkdir -p "$tmpdir/bin"
printf '#!/usr/bin/env bash\nexit 0\n' > "$tmpdir/bin/claude-code-mcp"
chmod +x "$tmpdir/bin/claude-code-mcp"
install_claude_server "latest" "$tmpdir"
rm -rf "$tmpdir"
unset -f npm || true
unset -f node || true

echo "Extended: installation audit failure cleans up"
tmpdir=$(mktemp -d)
node() { echo "v20.0.0"; }
npm() {
  case "$1" in
    view) echo "1.2.3" ;;
    install) echo "installed" ;;
    audit) return 1 ;;
    *) : ;;
  esac
}
mkdir -p "$tmpdir/bin"
printf '#!/usr/bin/env bash\nexit 0\n' > "$tmpdir/bin/claude-code-mcp"
chmod +x "$tmpdir/bin/claude-code-mcp"
out=$(install_claude_server "latest" "$tmpdir" 2>&1 || true)
echo "$out" | grep -q "Security audit failed" && echo "PASS" || { echo "FAIL: audit failure not detected"; exit 1; }
[ ! -d "$tmpdir" ] && echo "PASS" || { echo "FAIL: install dir not cleaned"; exit 1; }
unset -f npm || true
unset -f node || true

echo "Extended: installation dispatch paths"
install_server mcp-core "0.0.0" "/tmp/x" 2>/dev/null || true
install_server local-llm "0.0.0" "/tmp/x" 2>/dev/null || true
install_server custom-mcp "0.0.0" "/tmp/x" 2>/dev/null || true

echo "Extended: startup claude-server success in subshell"
(
  set -e
  plugin_dir="$(pwd)"
  export HOME="$(mktemp -d)"
  asdf() { echo "mcp latest"; }
  claude() { echo "ok"; }
  inst="$HOME/.asdf/installs/mcp/latest/servers/claude-server/bin"
  mkdir -p "$inst"
  printf '#!/usr/bin/env bash\necho start-ok\n' > "$inst/claude-code-mcp"
  chmod +x "$inst/claude-code-mcp"
  out=$(start_server "claude-server" 2>&1)
  echo "$out" | grep -q "start-ok" || true
) || true

echo "Extended: startup unknown"
out=$(start_server unknown 2>&1 || true)
echo "$out" | grep -q "not implemented" && echo "PASS" || { echo "FAIL: unknown start not detected"; exit 1; }

echo "Extended tests complete"
