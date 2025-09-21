#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
trace_dir="$repo_root/coverage"
trace_file="$trace_dir/trace.log"

mkdir -p "$trace_dir"
rm -f "$trace_file"

# Trace test execution and capture file:line hits
export PS4='+ ${BASH_SOURCE}:${LINENO}: '

(
  cd "$repo_root"
  bash -x test/test.sh 2>"$trace_file" || true
)

# Normalize paths and extract hits
hits_file="$trace_dir/hits.txt"
sed -E "s|^\+\+?\s+||; s|^$repo_root/||; s|^\./||" "$trace_file" \
  | awk -F: 'NF>=2 {file=$1; line=$2; if (file ~ /^(bin\/.+|lib\/.+\.bash)$/ && line ~ /^[0-9]+$/) {print file ":" line}}' \
  | sort -u > "$hits_file"

total_exec_lines=0
total_covered_lines=0

printf "%s\n" ""
printf "%s\n" "Bash trace coverage (approximate)"
printf "%s\n" "---------------------------------"

# Collect candidate files
files=()
while IFS= read -r file; do files+=("${file#./}"); done < <(
  cd "$repo_root" && {
    find bin -maxdepth 1 -type f 2>/dev/null
    find lib -type f -name "*.bash" 2>/dev/null
  }
)

for f in "${files[@]}"; do
  # Count executable lines: exclude blanks and comments
  total=$(grep -n '.*' "$repo_root/$f" | sed -E '/^[[:space:]]*($|#)/d' | wc -l | tr -d ' ')
  [ "$total" -eq 0 ] && continue
  covered=$(awk -F: -v FF="$f" '$1==FF {print $2}' "$hits_file" | sort -n | uniq | wc -l | tr -d ' ')
  pct=0
  if [ "$total" -gt 0 ]; then
    pct=$(( 100 * covered / total ))
  fi
  printf "%5s%%  %4d/%-4d  %s\n" "$pct" "$covered" "$total" "$f"
  total_exec_lines=$(( total_exec_lines + total ))
  total_covered_lines=$(( total_covered_lines + covered ))
done

overall=0
if [ "$total_exec_lines" -gt 0 ]; then
  overall=$(( 100 * total_covered_lines / total_exec_lines ))
fi

printf "%s\n" "---------------------------------"
printf "%5s%%  %4d/%-4d  overall\n" "$overall" "$total_covered_lines" "$total_exec_lines"

printf "%s\n" ""
echo "Trace log: $trace_file"
echo "Hits: $hits_file"

if [ "$overall" -lt 90 ]; then
  printf "%s\n" ""
  echo "Coverage below 90%. Consider adding tests."
  exit 2
fi
