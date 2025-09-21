#!/usr/bin/env bats

load 'bats-support/load'
load 'bats-assert/load'

setup() {
  export plugin_dir="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  load '../lib/utils.bash'
}

@test "install_claude_server latest with stubs" {
  node() { echo "v20.0.0"; }
  npm() {
    case "$1" in
      view) echo ok ;;
      install) echo ok ;;
      audit) echo ok ;;
      *) : ;;
    esac
  }
  tmpdir=$(mktemp -d)
  mkdir -p "$tmpdir/bin"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$tmpdir/bin/claude-code-mcp"
  chmod +x "$tmpdir/bin/claude-code-mcp"
  run install_claude_server latest "$tmpdir"
  [ "$status" -eq 0 ]
  [[ "$output" == *"installed successfully"* ]]
}

@test "install_github_server latest with curl stub" {
  curl() {
    if echo "$*" | grep -q "/releases/latest"; then
      echo '{"assets":[{"browser_download_url":"https://example.com/server-github-linux-x64"}]}'
      return 0
    fi
    if [ "$2" = "-o" ]; then
      printf '#!/usr/bin/env bash\nexit 0\n' > "$3"
      return 0
    fi
    return 0
  }
  tmpdir=$(mktemp -d)
  run install_github_server latest "$tmpdir"
  [ "$status" -eq 0 ]
  [[ -x "$tmpdir/github-server" ]]
}
