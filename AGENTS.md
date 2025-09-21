# Repository Guidelines

## Project Structure & Module Organization
- `bin/`: asdf entrypoints (`install`, `download`, `list-all`) and plugin commands: `mcp-list-servers`, `mcp-install`, `mcp-start`, `mcp-status`.
- `lib/`: shared Bash. `lib/utils.bash` orchestrates domain modules in `lib/domains/{validation,installation,startup}.bash`.
- `test/`: Bats specs (`*.bats`) plus a simple fallback runner (`test/test.sh`).
- `.github/workflows/ci.yml`: CI for ShellCheck, shfmt, Bats, and Trivy.

## Build, Test, and Development Commands
- Lint: `shellcheck bin/* lib/**/*.bash`
- Format: `shfmt -i 2 -sr -w bin lib test`
- Tests (Bats): `bats test/` (install bats-core/support/assert locally)
- Fallback tests: `bash test/test.sh`
- Quick try: `bin/mcp-list-servers`, `bin/mcp-install claude-server latest ~/.asdf/installs/mcp/latest/servers/claude-server`, `bin/mcp-start claude-server`

## Coding Style & Naming Conventions
- Bash with `set -euo pipefail`; prefer POSIX-compatible constructs.
- Indentation: 2 spaces. Functions: lower_snake_case. Scripts in `bin/` use hyphen-case; libraries end with `.bash`.
- Keep `bin/*` thin; put logic in `lib/domains/*` and orchestrate via `lib/utils.bash`.
- Use `fail "message"` for fatal errors; document any ShellCheck disables with a reason.

## Testing Guidelines
- Add Bats tests under `test/*.bats`; name after function/command (e.g., `utils.bats`).
- Mock external tools (`node`, `npm`, `asdf`) where needed.
- Cover new/changed functions; keep `test/test.sh` updated for smoke checks.

## Commit & Pull Request Guidelines
- Commits: short, imperative (e.g., "Add bin/mcp-status", "Fix CI shfmt action").
- PRs: clear summary, rationale, usage notes, and linked issues.
- CI must be green (ShellCheck, shfmt, Bats, Trivy). Run checks locally before pushing.

## Security & Configuration Tips
- Claude server install requires Node.js ≥20 and npm. Verify with `node --version`.
- Optional: set `GITHUB_API_TOKEN` to reduce GitHub API throttling.
- Avoid echoing secrets; validate inputs and paths; keep scripts idempotent.
