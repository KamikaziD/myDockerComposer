#!/bin/bash

. ./scripts/common/fonts.sh
. ./scripts/common/functions.sh

global working_dir

if [ -z "$1" ]; then
  echo "Error: Project Type not supplied."
  exit 1
else
  project_type="$1"
fi

handle_menu() {
  local choice
  read -p "Enter your choice: " choice
  case $choice in
    "1")
      clear
      bash ./scripts/js_ts/nextFunctions.sh "${project_type}" ;;
    "2") check_doc_com;;
    "b" | "B")
      clear
      exit 0 ;;
  esac
}

print_menu() {
    clear
    echo
    echo "${BOLDBLUE}NextJS Docker Generator${ENDCOLOR}"
    echo
    echo "${UNDERLINEYELLOW} Select action type:${ENDCOLOR}"
    echo "${ITALICBLUE}1. Generate ${BOLDYELLOW}docker.compose.yml${ENDCOLOR}"
    echo "${ITALICBLUE}2. Check if ${BOLDYELLOW}Docker & Docker Compose${ENDCOLOR} is installed"
    echo
    echo "${ENDCOLOR}Choose (1-2) or back (b):"
}

while true; do
  print_menu
  handle_menu
done

#while true; do
#  print_menu
#  handle_menu
#done


