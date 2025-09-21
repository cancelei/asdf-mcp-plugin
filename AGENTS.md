# Repository Guidelines

## Project Structure & Modules
- `bin/`: asdf entrypoints — `install`, `download`, `list-all` — plus plugin commands `mcp-list-servers`, `mcp-install`, `mcp-start`, `mcp-status`.
- `lib/`: shared Bash. `lib/utils.bash` orchestrates domain modules in `lib/domains/{validation,installation,startup}.bash`.
- `test/`: Bats specs (`*.bats`) and a simple fallback runner (`test/test.sh`).
- `.github/workflows/ci.yml`: ShellCheck, shfmt, Bats, and Trivy checks.

## Build, Test, and Dev Commands
- Lint: `shellcheck bin/* lib/**/*.bash`
- Format: `shfmt -i 2 -sr -w bin lib test`
- Tests (Bats): `bats test/` (CI clones bats-support/assert; locally install as needed)
- Fallback tests: `bash test/test.sh`
- Try commands locally: `bin/mcp-list-servers`, `bin/mcp-install claude-server latest ~/.asdf/installs/mcp/latest/servers/claude-server`, `bin/mcp-start claude-server`

## Coding Style & Naming
- Bash with `set -euo pipefail`. Prefer POSIX-compatible constructs.
- Indentation 2 spaces; wrap long lines thoughtfully.
- Functions: lower_snake_case; files: hyphen-case for `bin/*`, `.bash` for libraries.
- Keep logic in domain modules; `bin/*` should stay thin shims.
- Use `fail "message"` for fatal errors; add ShellCheck disables sparingly with rationale.

## Testing Guidelines
- Write Bats tests in `test/*.bats`; describe behavior, not implementation.
- Name tests after function/command (e.g., `utils.bats`).
- Mock external tools (e.g., `node`, `npm`, `asdf`) using bats-support/assert.
- Aim to cover new/changed functions; keep `test/test.sh` in sync for basic smoke tests.

## Commit & Pull Request Guidelines
- Commit messages: short, imperative (e.g., "Add bin/mcp-status", "Fix CI shfmt action").
- PRs must include: clear summary, rationale, usage notes, and linked issues.
- CI must be green (ShellCheck, shfmt, Bats, Trivy). Run locally before pushing.

## Security & Configuration Tips
- Claude server install requires Node.js ≥20 and npm. Validate with `node --version`.
- Optional: set `GITHUB_API_TOKEN` to avoid API throttling for GitHub downloads.
- Do not echo secrets in logs. Avoid path traversal in install paths. Keep scripts idempotent.

## Agent-Specific Instructions
- Do not rename public `bin/*` entrypoints without updating docs/tests.
- Preserve domain boundaries (`validation`, `installation`, `startup`). Add new domains if scope grows.
- Keep changes minimal and focused; prefer small, reviewable patches.
