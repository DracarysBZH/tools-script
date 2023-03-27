#!/bin/bash

#############
#   Const   #
#############
NC="\033[0m"
GREEN="\033[1;32m"
USERNAME="laurine.sorel.ext"

#############
# Functions #
#############

function interactive_select_option {
    # little helpers for terminal print control and key input
    ESC=$( printf "\033")
    cursor_blink_on()  { printf "$ESC[?25h"; }
    cursor_blink_off() { printf "$ESC[?25l"; }
    cursor_to()        { printf "$ESC[$1;${2:-1}H"; }
    print_option()     { printf "   $1 "; }
    print_selected()   { printf "  $ESC[7m $1 $ESC[27m"; }
    get_cursor_row()   { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo "${ROW#*[}"; }
    key_input()        { read -s -n3 key 2>/dev/null >&2
                         if [[ $key = $ESC[A ]]; then echo up;    fi
                         if [[ $key = $ESC[B ]]; then echo down;  fi
                         if [[ $key = ""     ]]; then echo enter; fi; }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=$(get_cursor_row)
    local startrow=$(($lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $(($startrow + $idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case $(key_input) in
            enter) break;;
            up)    ((selected--));
                   if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
            down)  ((selected++));
                   if [ "$selected" -ge $# ]; then selected=0; fi;;
        esac
    done

    # cursor position back to normal
    cursor_to "$lastrow"
    printf "\n"
    cursor_blink_on
    return $selected
}

function install_glab {
  if ! which glab >/dev/null; then
    brew install glab
  fi
}

function extract_branch_name {
  BRANCH=$(git rev-parse --abbrev-ref HEAD)
  BRANCH_TYPE=$(echo "$BRANCH" | cut -d'/' -f1)
  BRANCH_NAME=$(echo "$BRANCH" | cut -d'/' -f2)
  ISSUE_NUMBER=$(echo "$BRANCH_NAME" | cut -d'-' -f1)
  MR_TITLE="${BRANCH_TYPE}(${1}): ${2} (#${ISSUE_NUMBER})"
  echo "$MR_TITLE"
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
OPTIONS=("dashboard" "developer" "config")
interactive_select_option "${OPTIONS[@]}"
MR_TYPE_INDEX=$?

echo ""
echo -n "MR Title: "
read -r TITLE
echo ""

echo "-------------------------"
echo ""
echo -n "The MR will have the following title: "
MR_TITLE=$(extract_branch_name "${OPTIONS[$MR_TYPE_INDEX]}" "${TITLE}")
echo -e "${GREEN}$MR_TITLE${NC}"
echo ""
echo "-------------------------"

gitlab_auth
glab mr create --draft --title "${MR_TITLE}" --remove-source-branch --target-branch main --squash-before-merge --fill --assignee "${USERNAME}"