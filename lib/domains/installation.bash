# Domain: Server Installation
# Functions for installing specific MCP servers

install_claude_server() {
  local version="$1"
  local install_path="$2"

  echo "Installing Claude server version $version"

  validate_node_version
  validate_npm
  validate_claude_version "$version"

  # Install the package
  if [ "$version" = "latest" ]; then
    npm install @steipete/claude-code-mcp@latest --prefix "$install_path" || {
      rm -rf "$install_path"
      fail "Failed to install Claude server"
    }
  else
    npm install "@steipete/claude-code-mcp@$version" --prefix "$install_path" || {
      rm -rf "$install_path"
      fail "Failed to install Claude server"
    }
  fi

  # Run security audit
  (cd "$install_path" && npm audit --audit-level=moderate) || {
    rm -rf "$install_path"
    fail "Security audit failed: vulnerabilities found in dependencies"
  }

  # Verify installation
  if [ ! -x "$install_path/bin/claude-code-mcp" ]; then
    rm -rf "$install_path"
    fail "Installation verification failed: binary not found or not executable"
  fi

  echo "Claude server installed successfully to $install_path"
}

install_mcp_core() {
  local version="$1"
  local install_path="$2"

  echo "Installing MCP core version $version"
  # Implementation specific to MCP core
}

install_local_llm() {
  local version="$1"
  local install_path="$2"

  echo "Installing Local LLM server version $version"
  # Implementation specific to Local LLM
}

install_custom_mcp() {
  local version="$1"
  local install_path="$2"

  echo "Installing Custom MCP server version $version"
  # Implementation specific to Custom MCP
}