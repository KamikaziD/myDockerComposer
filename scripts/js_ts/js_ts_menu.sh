#!/bin/bash

. ./scripts/common/functions.sh

#declare -A selected=([1]=1 [2]=0 [3]=0 [4]=0)
declare -A fe_be_selected=([1]=1 [2]=0)

declare -A @project_name
declare -A @selected_type=0


declare -A project_type=(
    [1]="NextJS"
    [2]="NodeJS"
)

print_project_type_menu() {
  clear
  echo "Choose your project type:"
  for ((i = 1; i <= ${#project_type[@]}; i++)); do
    if [[ ${fe_be_selected[$i]} == 1 ]]; then
      echo "$i. [X] ${project_type[$i]}"
    else
      echo "$i. [ ] ${project_type[$i]}"
    fi
  done
}

while true; do
  print_project_type_menu

  read -p "Select project type to create (1 or 2) or ('c' to continue 'b' back): " choice

  if [[ $choice == 'b' || $choice == 'B' ]]; then
#    echo "Exiting..."
    break
  fi

  if [[ $choice == 'c' || $choice == 'C' ]]; then
    echo "Please select additional services"
    bash ./scripts/js_ts/nextDocCom.sh "${selected_type}"
#    handle_selected_services
  fi

  if [[ $choice =~ ^[1-2]$ ]]; then
    if [[ ${fe_be_selected[$choice]} == 1 ]]; then
      if [[ $choice == 1 ]]; then
        fe_be_selected[1]=0
        fe_be_selected[2]=1
        selected_type=1
      else
        fe_be_selected[1]=1
        fe_be_selected[2]=0
        selected_type=0
      fi
    else
      if [[ $choice == 1 ]]; then
        fe_be_selected[1]=1
        fe_be_selected[2]=0
        selected_type=0
      else
        fe_be_selected[1]=0
        fe_be_selected[2]=1
        selected_type=1
      fi
    fi
  fi
#  handle_selected_services
done