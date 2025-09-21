#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob globstar

echo "Running ShellCheck..."
files=(bin/* lib/**/*.bash scripts/*.sh test/*.sh check_ci.sh)
existing=()
for f in "${files[@]}"; do
  [ -e "$f" ] && existing+=("$f")
done
if [ ${#existing[@]} -gt 0 ]; then
  shellcheck --severity=error "${existing[@]}"
else
  echo "No shell files found to lint."
fi

echo "Running yamllint..."
if command -v yamllint >/dev/null 2>&1; then
  yamllint -d '{extends: default, rules: {line-length: {max: 140}, truthy: disable}}' .github/workflows
else
  echo "yamllint not installed; skipping YAML lint."
fi

echo "Lint checks completed."
