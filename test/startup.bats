#!/usr/bin/env bats

load 'bats-support/load'
load 'bats-assert/load'

setup() {
  export plugin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  load '../lib/utils.bash'
}

@test "get_install_path returns expected path" {
  asdf() { echo "mcp latest"; }
  run get_install_path "claude-server"
  [ "$status" -eq 0 ]
  expected="$HOME/.asdf/installs/mcp/latest/servers/claude-server"
  [ "$output" = "$expected" ]
}

@test "start_server errors when not installed" {
  asdf() { echo "mcp latest"; }
  run start_server "claude-server"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not installed"* ]]
}
