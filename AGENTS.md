# Agent Guidelines for asdf-mcp-plugin

## Build/Lint/Test Commands
- **Lint**: `shellcheck bin/* lib/**/*.bash`
- **Format**: `shfmt -i 2 -sr -w bin lib test`
- **All Tests**: `bats test/` (requires bats-support/assert locally)
- **Single Test**: `bats test/utils.bats` or `bats test/utils.bats:13` (specific test)
- **Fallback Tests**: `bash test/test.sh`
- **CI Check**: `bash check_ci.sh`

## Code Style Guidelines
- **Bash**: Use `set -euo pipefail`; prefer POSIX-compatible constructs
- **Formatting**: 2-space indentation; wrap long lines thoughtfully
- **Naming**: Functions in lower_snake_case; files hyphen-case for `bin/*`, `.bash` for libraries
- **Structure**: Keep logic in domain modules (`lib/domains/`); `bin/*` as thin shims
- **Error Handling**: Use `fail "message"` for fatal errors; add ShellCheck disables with rationale
- **Imports**: Source domain modules in `lib/utils.bash`; no external dependencies without validation
- **Security**: Never echo secrets; prevent path traversal; validate inputs; keep scripts idempotent

## Testing Guidelines
- Write Bats tests in `test/*.bats`; describe behavior, not implementation
- Mock external tools (`node`, `npm`, `asdf`) using bats-support/assert
- Name test files after functions/commands; cover new/changed functions
- Keep `test/test.sh` in sync for basic smoke tests

## Agent-Specific Instructions
- Do not rename public `bin/*` entrypoints without updating docs/tests
- Preserve domain boundaries (`validation`, `installation`, `startup`)
- Run lint/format/tests before committing; ensure CI passes locally
