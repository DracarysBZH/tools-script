#!/bin/bash

#############
# Const     #
#############
NC="\033[0m"
GREEN="\033[1;32m"

#############
# Import    #
#############

source $(dirname "$0")/utils/interactive_select_option.sh
source $(dirname "$0")/utils/extract_branch_name.sh

#######################################
#######################################

echo "-------------------------------"
echo "---  CREATE COMMIT MESSAGE  ---"
echo "-------------------------------"
echo ""

echo "Select the MR type: "
OPTIONS=("dashboard" "developer" "config")
interactive_select_option "${OPTIONS[@]}"
MR_TYPE_INDEX=$?

echo ""
echo -n "Commit message: "
read -r TITLE
echo ""

echo "-------------------------"
echo ""
echo -n "The commit message is as follow: "
COMMIT_MESSAGE=$(extract_branch_name "${OPTIONS[$MR_TYPE_INDEX]}" "${TITLE}")
echo -e "${GREEN}$COMMIT_MESSAGE${NC}"
echo ""
echo "-------------------------"
