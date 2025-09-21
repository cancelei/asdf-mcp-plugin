# Testing Playbook for AI Agents

Goal: Raise approximate Bash coverage to 90%+ and keep tests fast, hermetic, and platform‑agnostic.

## Test Types
- Bats tests: add under `test/*.bats` for unit/behavior tests.
- Fallback smoke tests: extend `test/test.sh` when Bats isn’t available locally.

## Running
- All tests: `bats test/` (install bats-core/support/assert locally).
- Fallback: `bash test/test.sh`.
- Coverage (approximate via xtrace): `./scripts/coverage.sh`.

## Stubbing & Isolation
- Mock external tools by defining shell functions before invoking code:
  ```bash
  node() { echo "v20.0.0"; }
  npm() { case "$1" in view|install|audit) return 0;; esac; }
  asdf() { echo "mcp latest"; }
  claude() { echo "ok"; }
  ```
- For installers, pre-create expected outputs (e.g., `"$tmp/bin/claude-code-mcp"`) and `chmod +x` to satisfy verification.
- Avoid real network and filesystem mutations; use `mktemp -d` and clean up.

## What to Cover
- lib/utils.bash: `list_servers`, `install_server` (all cases), `check_status`.
- lib/domains/validation.bash: happy and failure paths for validators.
- lib/domains/installation.bash: `install_claude_server latest` and pinned version with mocks; negative paths (invalid version, audit failure).
- lib/domains/startup.bash: path missing vs present, `claude` missing vs present. Avoid exec by running in a subshell and intercepting the binary path.
- bin/* shims: verify usage/help and basic invocation without side effects (use temp dirs and PATH overrides).

## Patterns & Conventions
- Use 2‑space indent; `set -euo pipefail` in tests and scripts.
- Name tests after function/command (`utils.bats`, `installation.bats`).
- Prefer Bats assertions; for fallback, use `|| true` to capture failures.

## Success Criteria
- `./scripts/coverage.sh` reports ≥90% overall.
- CI green: ShellCheck, shfmt, Bats, Trivy.
- Tests hermetic: no network, no secrets, no global state.
