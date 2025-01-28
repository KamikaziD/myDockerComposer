#!/bin/bash

. ./scripts/wordpress/wpFunctions.sh
. ./scripts/common/fonts.sh

print_menu() {
    clear
    echo
#    print_banner
    echo -e "${BOLDBLUE}Wordpress Docker Generator${ENDCOLOR}"
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
