#!/bin/bash

# - INPUT (git branch name):
#   - feat/203-branch-name
# - OUTPUT (message):
#   - feat(dashboard): this is the message (#203)
function extract_branch_name {
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  BRANCH_TYPE=$(echo "$BRANCH" | cut -d'/' -f1)
  BRANCH_NAME=$(echo "$BRANCH" | cut -d'/' -f2)
  ISSUE_NUMBER=$(echo "$BRANCH_NAME" | cut -d'-' -f1)
  MESSAGE="${BRANCH_TYPE}(${1}): ${2} (#${ISSUE_NUMBER})"
  echo "$MESSAGE"
}