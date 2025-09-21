#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
MIN_COVER=${MIN_COVER:-90}
COVER_MODE=${COVER_MODE:-functions}  # functions|lines
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
  | awk -F: 'NF>=2 {file=$1; line=$2; if (file ~ /^lib\/.+\.bash$/ && line ~ /^[0-9]+$/) {print file ":" line}}' \
  | sort -u > "$hits_file"

total_exec_lines=0
total_covered_lines=0

printf "%s\n" ""
printf "%s\n" "Bash trace coverage (approximate)"
printf "%s\n" "---------------------------------"

# Collect candidate files (lib only)
files=()
while IFS= read -r file; do files+=("${file#./}"); done < <(
  cd "$repo_root" && find lib -type f -name "*.bash" 2>/dev/null
)

for f in "${files[@]}"; do
  if [ "$COVER_MODE" = "lines" ]; then
    # Line-based mode
    total=$(awk '{print NR ":" $0}' "$repo_root/$f" \
      | sed -E -n '/^[[:space:]]*($|#)/!p' \
      | sed -E '/^[[:space:]]*([{}]|;;|fi|then|do|done|esac|else)$/d' \
      | sed -E '/^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(\)[[:space:]]*\{$/d' \
      | sed -E '/^[[:space:]]*case .+ in[[:space:]]*$/d' \
      | wc -l | tr -d ' ')
    [ "$total" -eq 0 ] && continue
    covered=$(awk -F: -v FF="$f" '$1==FF {print $2}' "$hits_file" | sort -n | uniq | wc -l | tr -d ' ')
  else
    # Function-based mode: count functions and mark covered if any line in range executed
    mapfile -t ranges < <(awk '
      /^[[:space:]]*[A-Za-z_][A-Za-z0-9_]*[[:space:]]*\(\)[[:space:]]*\{/ { if (infunc) { print start ":" NR-1 }; start=NR; infunc=1; }
      END { if (infunc) print start ":" NR }
    ' "$repo_root/$f")
    total=${#ranges[@]}
    [ "$total" -eq 0 ] && continue
    covered=0
    if [ -s "$hits_file" ]; then
      # Build an associative array of hit lines for this file
      mapfile -t hits < <(awk -F: -v FF="$f" '$1==FF {print $2}' "$hits_file" | sort -n | uniq)
      for r in "${ranges[@]}"; do
        start=${r%:*}; end=${r#*:}
        hit_found=0
        for hl in "${hits[@]}"; do
          if [ "$hl" -ge "$start" ] && [ "$hl" -le "$end" ]; then
            hit_found=1; break
          fi
        done
        [ "$hit_found" -eq 1 ] && covered=$((covered+1))
      done
    fi
  fi
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

if [ "$MIN_COVER" -gt 0 ] && [ "$overall" -lt "$MIN_COVER" ]; then
  printf "%s\n" ""
  echo "Coverage below ${MIN_COVER}%. Consider adding tests."
  exit 2
fi
