#!/bin/bash

. ./scripts/common/fonts.sh


handle_menu() {
  local choice
  read -p "Enter your choice: " choice
  case $choice in
    "1")
      clear
      ./scripts/nextjs/nextFunctions.sh ;;
    "2") echo "check_docker_and_compose";;
    "b" | "B")
      clear
      exit 0 ;;
  esac
}

print_menu() {
    clear
    echo
#    print_banner
    echo -e "${BOLDBLUE} NextJS Docker Generator${ENDCOLOR}"
    echo
    echo -e "${UNDERLINEYELLOW} Select action type:${ENDCOLOR}"
    echo -e "${ITALICBLUE}1. Generate ${BOLDYELLOW}docker.compose.yml${ENDCOLOR}"
    echo -e "${ITALICBLUE}2. Check if ${BOLDYELLOW}Docker & Docker Compose${ENDCOLOR} is installed"
    echo
    echo -e "${ENDCOLOR}Choose (1-2) or back (b):"
}

while true; do
  print_menu
  handle_menu
done

#while true; do
#  print_menu
#  handle_menu
#done


