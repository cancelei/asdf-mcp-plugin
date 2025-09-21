# Contributing to asdf-mcp-plugin

## Development Setup
1. Clone the repo.
2. Ensure Node.js ≥20 and npm are installed.

## Commands
- Lint: `shellcheck bin/* lib/**/*.bash`
- Format: `shfmt -i 2 -sr -w bin lib test`
- Tests (Bats): `bats test/` (install bats-core, bats-support, bats-assert locally)
- Fallback tests: `bash test/test.sh`

## CI Checks
PRs run:
- **Lint**: ShellCheck for bash consistency and security.
- **Test**: Functional tests with Bats/bash.
- **Consistency**: shfmt for formatting.
- **Security**: Trivy for vulnerabilities, npm audit in installs.

Ensure all pass before merging.

## Style & Conventions
- Bash with `set -euo pipefail`; prefer POSIX-compatible constructs.
- Indentation: 2 spaces. Functions: lower_snake_case. Scripts in `bin/` use hyphen-case; libraries end with `.bash`.
- Keep command shims thin in `bin/`; place logic in `lib/domains/*` and orchestrate via `lib/utils.bash`.
- Use `fail "message"` for fatal errors; document any ShellCheck disables.

## Pull Requests
- Use imperative commit messages (e.g., "Add bin/mcp-status", "Fix CI shfmt action").
- Include summary, rationale, usage notes, and linked issues.
- CI must be green (ShellCheck, shfmt, Bats, Trivy). Run local checks first.
- See AGENTS.md for repository-wide guidelines.
