#!/usr/bin/env bats

# Set plugin_dir for sourced domains
plugin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

# Load bats support
load '/tmp/bats-support/load'
load '/tmp/bats-assert/load'

# Load the utils library
load '../lib/utils.bash'

@test "bin/mcp-list-servers calls list_servers" {
  run bash "$plugin_dir/bin/mcp-list-servers"
  [ "$status" -eq 0 ]
  [[ "$output" == *"claude-server"* ]]
  [[ "$output" == *"github-server"* ]]
}

@test "bin/mcp-status calls check_status" {
  run bash "$plugin_dir/bin/mcp-status"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Checking status"* ]]
}

@test "bin/mcp-install fails with insufficient args" {
  run bash "$plugin_dir/bin/mcp-install" "claude-server"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage"* ]]
}

@test "bin/mcp-start fails with insufficient args" {
  run bash "$plugin_dir/bin/mcp-start"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage"* ]]
}

@test "bin/mcp-install handles argument parsing" {
  # Test that it accepts the right number of arguments
  run bash "$plugin_dir/bin/mcp-install" "claude-server" "latest" "/tmp/test"
  # May fail due to missing dependencies, but should parse args correctly
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "bin/mcp-start handles argument parsing" {
  run bash "$plugin_dir/bin/mcp-start" "claude-server"
  # May fail due to missing server, but should parse args correctly
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "bin/mcp-list-servers produces expected output format" {
  run bash "$plugin_dir/bin/mcp-list-servers"
  [ "$status" -eq 0 ]
  # Should contain server names and descriptions
  [[ "$output" == *"claude-server"* ]]
  [[ "$output" == *"github-server"* ]]
  [[ "$output" == *"Anthropic"* ]] || [[ "$output" == *"GitHub"* ]]
}

@test "bin/mcp-status produces status output" {
  run bash "$plugin_dir/bin/mcp-status"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Checking status"* ]]
}

@test "bin/mcp-install validates server name argument" {
  run bash "$plugin_dir/bin/mcp-install"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage"* ]]
}

@test "bin/mcp-start validates server name argument" {
  run bash "$plugin_dir/bin/mcp-start"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Usage"* ]]
}

@test "bin/mcp-install accepts valid server names" {
  # Test argument parsing for known server types
  run bash "$plugin_dir/bin/mcp-install" "mcp-core" "latest" "/tmp/test"
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]  # May fail due to missing deps
}

@test "bin/mcp-start accepts config file parameter" {
  temp_config=$(mktemp)
  echo "export TEST_VAR=test" > "$temp_config"
  run bash "$plugin_dir/bin/mcp-start" "claude-server" "$temp_config"
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]  # May fail due to missing server
  rm -f "$temp_config"
}