#!/bin/bash

test_function() {
  local project_name
  if [ -z "$1" ]; then
    echo "Error: Project Name is required."
    exit 1
  else
    echo "Project Name: $1"
    project_name=$1
    echo "Project Name: ${project_name}"
  fi
  return 0
}

echo "Test with params:"
test_function "test_function" results
echo "Test without params:"
test_function

echo "RESULTS: ${results}"