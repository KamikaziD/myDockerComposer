#!/bin/bash

GREEN='\033[1;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
WHITE='\033[0;36m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
ENDCOLOR='\033[0;29m'

NORMAL=0
BOLD=1
FAINT=2
ITALIC=3
UNDERLINE=4

BOLDRED=$(echo $RED|sed -e "s/\[./\[${BOLD}/")
BOLDYELLOW=$(echo $YELLOW|sed -e "s/\[./\[${BOLD}/")
UNDERLINEYELLOW=$(echo $YELLOW|sed -e "s/\[./\[${UNDERLINE}/")
ITALICBLUE=$(echo $BLUE|sed -e "s/\[./\[${ITALIC}/")
FAINTRED=$(echo $RED|sed -e "s/\[./\[${FAINT}/")

declare -A addons=(
  [1]="Generate Dockerfile"
  [2]="Generate docker.compose.yml"
)

declare -A selected

print_menu() {
    clear
    echo
    echo -e "${BOLDRED} pyDocCom${ENDCOLOR}"
    echo
    echo -e "${UNDERLINEYELLOW} Select action type:${ENDCOLOR}"
    echo -e "${ITALICBLUE}1. Generate ${BOLDYELLOW}Dockerfile${ENDCOLOR}"
    echo -e "${ITALICBLUE}2. Generate ${BOLDYELLOW}docker.compose.yml${ENDCOLOR}"
    echo "3. Print Key Details"
    # echo "2. Advanced"
    echo
    echo -e "${ENDCOLOR}Choose (1-3) or quit (q):"
}

print_choices() {
  for key in "${!addons[@]}"; do
    echo -e "${BOLDRED}${key}.${ENDCOLOR} ${ITALICBLUE}${addons[$key]}${ENDCOLOR}"
  done
  echo "Press enter to continue..."
  read -r
}

handle_menu() {
  local choice
  read -p "Enter your choice: " choice

  case "${choice}" in
#    "1") generate_key;;
    "1")
      print_choices;;
    "2") check_key_validity;;
    "3") print_key_details;;
    "q") exit 0;;
  esac
}

while True; do
  print_menu
  handle_menu
done