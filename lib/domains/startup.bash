# Domain: Server Startup
# Functions for starting MCP servers

# Get the install path for a server
get_install_path() {
  local server_name="$1"
  local version
  version=$(asdf current mcp 2>/dev/null | awk '{print $2}') || version="latest"
  echo "$HOME/.asdf/installs/mcp/$version/servers/$server_name"
}

# Start an MCP server
start_server() {
  local server_name="$1"
  local config="${2:-}"

  echo "Starting $server_name server"

  local install_path
  install_path=$(get_install_path "$server_name")

  if [ ! -d "$install_path" ]; then
    fail "Server $server_name is not installed. Please install it first with 'asdf mcp install $server_name <version>'"
  fi

  case "$server_name" in
    claude-server)
      # Check if Claude CLI is available
      if ! command -v claude >/dev/null 2>&1; then
        fail "Claude CLI is not installed or not in PATH. Please install it and run 'claude --dangerously-skip-permissions' once."
      fi
      # Source config file if provided
      if [ -n "$config" ] && [ -f "$config" ]; then
        # Assume config is a bash file with env vars
        source "$config"
      fi
      # Run the claude-code-mcp binary
      exec "$install_path/bin/claude-code-mcp"
      ;;
    github-server)
      # Source config file if provided (likely contains GITHUB_TOKEN)
      if [ -n "$config" ] && [ -f "$config" ]; then
        source "$config"
      fi
      # Run the github-server binary
      exec "$install_path/github-server"
      ;;
    *)
      fail "Starting server $server_name is not implemented yet"
      ;;
  esac
}