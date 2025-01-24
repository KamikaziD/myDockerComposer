#!/bin/bash

. ./scripts/common/fonts.sh

handle_menu() {
  local choice
  # shellcheck disable=SC2162
  read -p "Enter your choice: " choice

  case "${choice}" in
    1)
      echo ""
      echo "PHP Selected"
      ./wpDocCom.sh ;;
#      sleep 2 ;;
    2)
      echo ""
      echo "Typescript/Javascript Selected"
      sleep 2 ;;
    3)
      echo ""
      echo "Python Selected"
      sleep 2 ;;
    "q" | "Q")
      clear
      echo "If you enjoy using this script then send Detmar some Windhoek Draughts!"
      echo "I think he will appreciate it"
      echo
      # shellcheck disable=SC2162
      exit 0;;
    *)
      echo "Invalid option. Press any key to continue..."
      read -n 1;;
  esac
}

print_menu() {
    clear
    echo
#    print_banner
    echo -e "${BOLDBLUE}Doc Com - Docker Compose Generator${ENDCOLOR}"
    echo
    echo -e "${UNDERLINEYELLOW} Select your preferred programming language:${ENDCOLOR}"
    echo -e "${ITALICBLUE}1. PHP${ENDCOLOR}"
    echo -e "${ITALICBLUE}2. Typescript / Javascript${ENDCOLOR}"
    echo -e "${ITALICBLUE}3. Python${ENDCOLOR} - ${BOLDRED}not available yet${ENDCOLOR}"
    echo
    echo -e "${ENDCOLOR}Choose (1-3) or quit (q):"
}

while true; do
  print_menu
  handle_menu
done