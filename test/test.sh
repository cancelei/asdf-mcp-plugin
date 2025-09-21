#!/bin/bash

# Unit tests using shunit2

# Set plugin_dir
plugin_dir="$(pwd)"

# Source utils
. ./lib/utils.bash

# Mock functions for testing
setUp() {
  # Mock external commands
  node() {
    echo "v20.0.0"
  }
  npm() {
    echo "installed"
  }
  asdf() {
    echo "mcp latest"
  }
}

testListServers() {
  output=$(list_servers)
  assertContains "claude-server" "$output"
  assertContains "mcp-core" "$output"
  assertContains "local-llm" "$output"
  assertContains "custom-mcp" "$output"
}

testInstallServerUnknown() {
  output=$(install_server "unknown" "1.0.0" "/tmp/test" 2>&1 || true)
  assertContains "Unknown server type" "$output"
}

testGetInstallPath() {
  output=$(get_install_path "claude-server")
  expected="$HOME/.asdf/installs/mcp/latest/servers/claude-server"
  assertEquals "$expected" "$output"
}

testValidateClaudeVersionLatest() {
  validate_claude_version "latest"
  # If no error, pass
}

testValidateClaudeVersionInvalid() {
  npm() {
    return 1
  }
  output=$(validate_claude_version "invalid" 2>&1 || true)
  assertContains "not found" "$output"
}

testCheckStatus() {
  output=$(check_status)
  assertContains "Checking status" "$output"
}

# Load shunit2
. ./shunit2