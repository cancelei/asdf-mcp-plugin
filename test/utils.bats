#!/usr/bin/env bats

# Set plugin_dir for sourced domains
plugin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

# Load bats support
load 'bats-support/load'
load 'bats-assert/load'

# Load the utils library
load '../lib/utils.bash'

@test "list_servers outputs expected servers" {
  run list_servers
  [ "$status" -eq 0 ]
  [[ "$output" == *"claude-server"* ]]
  [[ "$output" == *"github-server"* ]]
  [[ "$output" == *"mcp-core"* ]]
}

@test "install_server fails for unknown server" {
  run install_server "unknown" "1.0.0" "/tmp/test"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown server type"* ]]
}

# Test install_claude_server with mocks
@test "install_claude_server success" {
  stub node 'echo "v20.0.0"'
  stub npm 'echo "version info"' : view
  stub npm 'echo "installed"' : install
  stub npm 'echo "audit passed"' : audit
  temp_dir=$(mktemp -d)
  run install_claude_server "latest" "$temp_dir"
  [ "$status" -eq 0 ]
  [[ "$output" == *"installed successfully"* ]]
  rm -rf "$temp_dir"
  unstub node
  unstub npm
}

# Test install_github_server with mocks
@test "install_github_server success" {
  stub curl 'echo "https://example.com/download"'
  stub curl 'echo "binary content"' : -o
  temp_dir=$(mktemp -d)
  run install_github_server "latest" "$temp_dir"
  [ "$status" -eq 0 ]
  [[ "$output" == *"installed successfully"* ]]
  [ -x "$temp_dir/github-server" ]
  rm -rf "$temp_dir"
  unstub curl
}

# Test start_server with mocks
@test "start_server claude-server" {
  stub claude 'echo "running"'
  stub asdf 'echo "mcp latest"'
  run start_server "claude-server"
  [ "$status" -eq 0 ]
  unstub claude
  unstub asdf
}

@test "start_server github-server" {
  stub asdf 'echo "mcp latest"'
  temp_dir=$(mktemp -d)
  mkdir -p "$temp_dir/github-server"
  echo "#!/bin/bash" > "$temp_dir/github-server"
  chmod +x "$temp_dir/github-server"
  # Mock get_install_path to return temp_dir
  stub get_install_path "echo '$temp_dir'"
  run start_server "github-server"
  [ "$status" -eq 0 ]
  rm -rf "$temp_dir"
  unstub asdf
  unstub get_install_path
}

# Security test: malicious install_path
@test "install_server prevents path traversal" {
  run install_server "claude-server" "latest" "../../../etc"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not found"* ]]  # Assuming validation catches it
}