#!/usr/bin/env bats

load 'bats-support/load'
load 'bats-assert/load'

setup() {
  export plugin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  load '../lib/utils.bash'
}

@test "list_servers includes known servers" {
  run list_servers
  [ "$status" -eq 0 ]
  [[ "$output" == *"claude-server"* ]]
  [[ "$output" == *"github-server"* ]]
  [[ "$output" == *"mcp-core"* ]]
}

@test "install_server unknown fails" {
  run install_server "unknown" "1.0.0" "/tmp/test"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown server type"* ]]
}
