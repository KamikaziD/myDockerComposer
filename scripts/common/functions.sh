#!/bin/bash

handle_project_directory() {
  local project_name

  if [ -z "$1" ]; then
    echo "Error: Something went wrong - please try again"
    exit 1
  else
    project_name=$1
  fi
  p_name="${project_name// /_}"
  cd "projects" || exit 1;
  if [ ! -d "${p_name}" ]; then
      echo "Creating new project folder..."
      mkdir "${p_name}"
      sleep 1
  else
    echo "Project directory already exists."
    read -p "Do you want to overwrite it? (y/N): " overwrite_choice
    if [[ $overwrite_choice == "y" || $overwrite_choice == "Y" ]]; then
      rm -rf "${p_name}"
      mkdir "${p_name}"
    else
      clear
      read -p "Please enter a project name: " new_project_name
      project_name="${new_project_name// /_}"
      mkdir "${new_project_name// /_}"
    fi
    ls
#    cd "projects" || exit 1
  fi
}