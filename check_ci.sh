#!/bin/bash

# Script to check GitHub Actions errors for commits on the current branch

BRANCH=$(git branch --show-current)
echo "Checking CI status for branch: $BRANCH"

# Get failed runs
FAILED_RUNS=$(gh run list --branch "$BRANCH" --status failure --json databaseId,displayTitle,conclusion --jq '.[] | select(.conclusion == "failure") | .databaseId')

if [ -z "$FAILED_RUNS" ]; then
  echo "No failed runs found. All good!"
  exit 0
fi

echo "Failed runs:"
for RUN_ID in $FAILED_RUNS; do
  echo "Run ID: $RUN_ID"
  gh run view "$RUN_ID" --log | grep -A 10 -B 10 "Error\|FAIL\|error"
done