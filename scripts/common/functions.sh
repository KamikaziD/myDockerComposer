#!/bin/bash

global g_project_name

handle_project_directory() {
  if [ -z "$1" ]; then
    echo "Error: Something went wrong - please try again"
    exit 1
  else
    g_project_name=$1
  fi
  p_name="${g_project_name// /_}"
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
      exit 1
    fi
  fi
}

find_function() {
  local search_string
  local new_string
  local file_name
  local dir_path

  if [ -z "$1" ] && [ -z "$2" ] && [ -z "$3" ] && [ -z "$4" ]; then
    echo "Parameter missing: "
    echo "Usage: find_function <search_string> <new_string> <file_name> <directory_path>"
    exit 1
  else
    search_string="$1"
    new_string="$2"
    file_name="$3"
    dir_path="$4"
    if [[ $dir_path != '.' ]]; then
      echo "Changing directory to: $dir_path"
      cd "${dir_path}" || exit 1
    fi
    lineNumber="$(grep -n "$search_string" "$file_name" | tail -n 1 | cut -d: -f1)"
    if [[ ${lineNumber} == "" ]]; then
      echo "No occurrences found"
      exit 0
    else
      # shellcheck disable=SC1004
      sed "${lineNumber}"'a\
'"  $new_string:"'
      ' < "${file_name}" >> tmp.yaml
      mv tmp.yaml "$file_name"
    fi
  fi
}

get_current_dir() {
  local directory
  directory=$(pwd)
  echo "${directory}"
}