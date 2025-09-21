# Contributing to asdf-mcp-plugin

## Development Setup
1. Clone the repo.
2. Ensure Node.js ≥20 and npm are installed.

## Running Tests
- Local: `bash test/test.sh`
- With Bats: `bats test/` (install Bats first)

## CI Checks
PRs run:
- **Lint**: ShellCheck for bash consistency and security.
- **Test**: Functional tests with Bats/bash.
- **Consistency**: shfmt for formatting.
- **Security**: Trivy for vulnerabilities, npm audit in installs.

Ensure all pass before merging.