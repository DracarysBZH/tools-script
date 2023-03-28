#!/bin/bash

#############
# Const     #
#############
NC="\033[0m"
GREEN="\033[1;32m"
USERNAME="laurine.sorel.ext"
LABELS="SQUAD:: 2"

#############
# Import    #
#############

source $(dirname "$0")/utils/interactive_select_option.sh
source $(dirname "$0")/utils/extract_branch_name.sh

#############
# Functions #
#############

function install_glab {
  if ! which glab >/dev/null; then
    brew install glab
  fi
}

function gitlab_auth {
  glab auth login --stdin < ~/.pat_gitlab
}

#######################################
#######################################

install_glab

echo "-------------------------"
echo "---     CREATE MR     ---"
echo "-------------------------"
echo ""

echo "Select the MR type: "
OPTIONS=("dashboard" "FileManagement" "file-stream")
interactive_select_option "${OPTIONS[@]}"
MR_TYPE_INDEX=$?

echo ""
echo -n "MR Title: "
read -r TITLE
echo ""

echo "-------------------------"
echo ""
echo -n "The MR will have the following title: "
TITLE_LOWERCASE=$(echo "${TITLE}" | tr "[:upper:]" "[:lower:]")
MR_TITLE=$(extract_branch_name "${OPTIONS[$MR_TYPE_INDEX]}" "${TITLE_LOWERCASE}")
echo -e "${GREEN}$MR_TITLE${NC}"
echo ""
echo "-------------------------"

gitlab_auth
glab mr create --draft --title "${MR_TITLE}" --remove-source-branch --target-branch main --squash-before-merge --fill --assignee "${USERNAME}" --label "${LABELS}"