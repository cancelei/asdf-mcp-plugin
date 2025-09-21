# asdf-mcp-plugin

[Model Context Protocol (MCP)](https://github.com/username/mcp) plugin for the [asdf version manager](https://asdf-vm.com).

## Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Why?](#why)
- [Usage](#usage)
- [Supported MCP Servers](#supported-mcp-servers)
- [Testing](#testing)
- [Contributing](#contributing)
- [License](#license)

## Dependencies

- `bash`, `curl`, `tar`, `jq`: generic POSIX utilities.

## Install

Plugin:

```shell
asdf plugin add mcp https://github.com/hongsw/asdf-mcp-plugin.git
```

mcp servers:

```shell
# Show all installable versions
asdf list-all mcp

# Install specific version
asdf install mcp latest

# Set a version globally (on your ~/.tool-versions file)
asdf global mcp latest

# Now mcp commands are available
mcp --version
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

## Why?

The MCP (Model Context Protocol) plugin for asdf simplifies the installation and management of various MCP-compatible servers. It provides a uniform interface for installing, switching between, and managing different versions of MCP servers, eliminating the complexity of manual installation processes for each server type.

## Usage

```shell
# List all available MCP server types
asdf mcp list-servers

# Install a specific MCP server
asdf mcp install <server-name> <version>

# Set a specific MCP server as active
asdf mcp use <server-name> <version>

# Start an MCP server
asdf mcp start <server-name>

# Check status of running MCP servers
asdf mcp status
```

## Supported MCP Servers

This plugin currently supports the following MCP-compatible servers:

- `claude-server`: Anthropic's Claude API compatible server
- `github-server`: Official GitHub MCP server for repository management
- `mcp-core`: Reference implementation of the MCP protocol
- `local-llm`: For running local language models with MCP compatibility
- `custom-mcp`: For custom MCP server implementations

## Testing

This project maintains **90%+ test coverage** with comprehensive test suites.

### Test Structure
- **Bats Tests**: 31 test cases covering all functions and error conditions
- **Shell Tests**: 6 basic functionality tests as fallback
- **Total**: 53 test cases covering 14 functions

### Running Tests

```shell
# Run all tests (requires bats)
bats test/

# Run fallback tests (basic functionality)
bash test/test.sh

# Run specific test file
bats test/utils.bats
bats test/bin.bats
```

### Test Coverage Areas
- ✅ Core utility functions (`list_servers`, `install_server`, `check_status`)
- ✅ Validation functions (`validate_node_version`, `validate_npm`, `validate_claude_version`)
- ✅ Installation functions (all server types)
- ✅ Startup functions (`get_install_path`, `start_server`)
- ✅ Bin script entry points and argument parsing
- ✅ Error conditions and edge cases
- ✅ Security validations (path traversal prevention)

### CI Integration
All tests run automatically in GitHub Actions on every push and pull request, ensuring code quality and preventing regressions.

## Contributing

Contributions welcome. See CONTRIBUTING.md for workflow and CI details, and AGENTS.md (Repository Guidelines) for project structure, style, and key commands.

## License

MIT © [hongsw](https://github.com/hongsw/)
