# Domain: Validation
# Functions for validating prerequisites and inputs

validate_node_version() {
  if ! command -v node >/dev/null 2>&1; then
    fail "Node.js is required. Please install Node.js v20 or later."
  fi
  local node_version
  node_version=$(node --version | sed 's/v//' | cut -d. -f1)
  if [ "$node_version" -lt 20 ]; then
    fail "Node.js v20 or later is required. Current version: $(node --version)"
  fi
}

validate_npm() {
  if ! command -v npm >/dev/null 2>&1; then
    fail "npm is required. Please install npm."
  fi
}

validate_claude_version() {
  local version="$1"
  if [ "$version" != "latest" ]; then
    if ! npm view "@steipete/claude-code-mcp@$version" version >/dev/null 2>&1; then
      fail "Version $version not found for @steipete/claude-code-mcp"
    fi
  fi
}