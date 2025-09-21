#!/usr/bin/env bats

# Set plugin_dir for sourced domains
plugin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

# Load the utils library
load '../lib/utils.bash'

@test "list_servers outputs expected servers" {
  run list_servers
  [ "$status" -eq 0 ]
  [[ "$output" == *"claude-server"* ]]
  [[ "$output" == *"mcp-core"* ]]
}

@test "install_server fails for unknown server" {
  run install_server "unknown" "1.0.0" "/tmp/test"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown server type"* ]]
}

# Test install_claude_server with mocks
@test "install_claude_server success" {
  # Mock functions
  stub node 'echo "v20.0.0"'
  stub npm 'echo "installed"'
  stub npm 'echo "audit passed"' : view
  # Create temp dir
  temp_dir=$(mktemp -d)
  run install_claude_server "latest" "$temp_dir"
  [ "$status" -eq 0 ]
  [[ "$output" == *"installed successfully"* ]]
  # Cleanup
  rm -rf "$temp_dir"
  unstub node
  unstub npm
}

# Test start_server with mocks
@test "start_server claude-server" {
  # Mock claude
  stub claude 'echo "running"'
  # Mock get_install_path
  stub get_install_path 'echo "/tmp/mock"'
  run start_server "claude-server"
  [ "$status" -eq 0 ]
  unstub claude
  unstub get_install_path
}

# Security test: malicious install_path
@test "install_server prevents path traversal" {
  run install_server "claude-server" "latest" "../../../etc"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]  # Assuming validation catches it
}