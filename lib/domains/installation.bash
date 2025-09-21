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

install_github_server() {
  local version="$1"
  local install_path="$2"

  echo "Installing GitHub MCP server version $version"

  local platform="linux"
  local arch="x64"
  local download_url

  if [ "$version" = "latest" ]; then
    # Get the latest release URL
    download_url=$(curl $curl_opts "https://api.github.com/repos/modelcontextprotocol/server-github/releases/latest" | grep "browser_download_url.*${platform}-${arch}" | cut -d '"' -f 4)
  else
    download_url="https://github.com/modelcontextprotocol/server-github/releases/download/${version}/server-github-${platform}-${arch}"
  fi

  if [ -z "$download_url" ]; then
    fail "Could not determine download URL for GitHub MCP server $version"
  fi

  mkdir -p "$install_path"
  curl $curl_opts -o "$install_path/github-server" "$download_url" || {
    rm -rf "$install_path"
    fail "Failed to download GitHub MCP server"
  }

  chmod +x "$install_path/github-server"

  echo "GitHub MCP server installed successfully to $install_path"
}

install_custom_mcp() {
  local version="$1"
  local install_path="$2"

  echo "Installing Custom MCP server version $version"
  # Implementation specific to Custom MCP
}