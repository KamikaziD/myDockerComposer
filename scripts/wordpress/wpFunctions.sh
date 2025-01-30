#!/bin/bash

. ./scripts/common/functions.sh

project_name=""
wp_version="latest"
php_version=""

cleanup() {
  echo "Cleaning up..."
  cd ..
  if [ -d "$project_name" ]; then
    echo "Removing $project_name directory..."
    rm -rf "$project_name"
  fi
}

#check_doc_com() {
#  clear
#  docker -v && docker compose version
#  # shellcheck disable=SC2162
#  read -p "Press Enter to continue..."
#}

handle_menu() {
  local choice
  # shellcheck disable=SC2162
  read -p "Enter your choice: " choice

  case "${choice}" in
    1) generate_doc_com;;
    2) check_doc_com;;
    "b" | "B")
      clear
#      echo "If you enjoy using this script then send Detmar some Windhoek Draughts!"
#      echo "I think he will appreciate it"
#      echo
      # shellcheck disable=SC2162
#      read -p "Press Enter to exit..."
      exit 0;;
    *)
      echo "Invalid option. Press any key to continue..."
      read -n 1;;
  esac
}

print_wp_version_menu() {
  clear
  echo "Choose your WordPress version:"
  echo "1. WordPress 5"
  echo "2. WordPress 6 with latest minor and patch version"
  echo "3. WordPress 6.7 with latest patch version"
  echo "4. WordPress 6.7.1"
  echo "5. Latest WordPress"
  echo "q. Quit"
}

print_php_version_menu() {
  clear
  echo "Choose your PHP version:"
  echo "1. PHP 8.1"
  echo "2. PHP 8.2"
  echo "3. PHP 8.3"
  echo "q. Quit"
}

print_php_version_menu_additional() {
  clear
  echo "Choose your PHP version:"
  echo "1. PHP 7.3"
  echo "2. PHP 8.1"
  echo "q. Quit"
}

handle_wp_version() {
  local choice
  read -p "Enter your choice: " choice

  case "${choice}" in
    1)
      wp_version="5"
      print_php_version_menu_additional
      handle_php_version_additional;;
    2)
      wp_version="6"
      print_php_version_menu
      handle_php_version;;
    3)
      wp_version="6.7"
      print_php_version_menu
      handle_php_version;;
    4)
      wp_version="6.7.1"
      print_php_version_menu
      handle_php_version;;
    5)
      wp_version="latest"
      php_version="";;
    "q" | "Q")
      cleanup
      exit 0;;
    *)
      echo "Invalid option. Press any key to continue..."
      # shellcheck disable=SC2162
      read -n 1;;
  esac
}

handle_php_version() {
  local choice
  # shellcheck disable=SC2162
  read -p "Enter your choice: " choice

  case "${choice}" in
    1) php_version="-php8.1";;
    2) php_version="-php8.2";;
    3) php_version="-php8.3";;
    "q" | "Q")
      cleanup
      exit 0;;
    *)
      echo "Invalid option. Press any key to continue..."
      read -n 1;;
  esac
}

create_readme() {
  clear
  echo "Generating README.md file..."
  # shellcheck disable=SC2129
  echo "# wpDocCom" >> README.md
  echo "## WordPress Docker Composer" >> README.md
  echo "" >> README.md
  echo "## Run the containers" >> README.md
  echo '```bash' >> README.md
  echo 'docker compose up -d' >> README.md
  echo '```' >> README.md
  echo "" >> README.md
  echo "## Stop the containers" >> README.md
  echo "" >> README.md
  echo '```bash' >> README.md
  echo 'docker compose down --remove-orphans' >> README.md
  echo '```' >> README.md
}

handle_php_version_additional() {
  local choice
  read -p "Enter your choice: " choice

  case "${choice}" in
    1) php_version="-php7.3";;
    2) php_version="-php8.1";;
    "q" | "Q") exit 0;;
    *)
      echo "Invalid option. Press any key to continue..."
      read -n 1;;
  esac
}

generate_env_file() {
  clear
  echo "Generating.env file..."
  # shellcheck disable=SC2129
  echo "# WORDPRESS" >> .env
  echo "WORDPRESS_DB_HOST=db:3306" >> .env
  echo "WORDPRESS_DB_USER=admin" >> .env
  echo "WORDPRESS_DB_PASSWORD=password" >> .env
  echo "WORDPRESS_DB_NAME=${project_name}_db" >> .env
  echo >> .env
  echo "# DB" >> .env
  echo "MYSQL_ROOT_PASSWORD=P@ssw0rd" >> .env
  # shellcheck disable=SC2016
  echo 'MYSQL_DATABASE=$WORDPRESS_DB_NAME' >> .env
  # shellcheck disable=SC2016
  echo 'MYSQL_USER=$WORDPRESS_DB_USER' >> .env
  # shellcheck disable=SC2016
  echo 'MYSQL_PASSWORD=$WORDPRESS_DB_PASSWORD' >> .env
  echo  >> .env
  echo "# PHPMYADMIN" >> .env
  echo "PMA_HOST=db" >> .env
  # shellcheck disable=SC2016
  echo 'PMA_USER=$WORDPRESS_DB_USER' >> .env
  # shellcheck disable=SC2016
  echo 'PMA_PASSWORD=$WORDPRESS_DB_PASSWORD' >> .env
}

generate_docker_compose_file() {
  project_name="${project_name// /_}"
  handle_project_directory "${project_name}"

  cd "$project_name" || return
  generate_env_file
  print_wp_version_menu
  handle_wp_version
  # shellcheck disable=SC2129
  echo "services:" >> docker-compose.yaml
  echo "  db:" >> docker-compose.yaml
  echo "    image: mysql:latest" >> docker-compose.yaml
  echo "    restart: always" >> docker-compose.yaml
  echo "    environment:" >> docker-compose.yaml
  # shellcheck disable=SC2016
  echo '      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}' >> docker-compose.yaml
  # shellcheck disable=SC2016
  echo '      MYSQL_DATABASE: ${MYSQL_DATABASE}' >> docker-compose.yaml
  # shellcheck disable=SC2016
  echo '      MYSQL_USER: ${MYSQL_USER}' >> docker-compose.yaml
  # shellcheck disable=SC2016
  echo '      MYSQL_PASSWORD: ${MYSQL_PASSWORD}' >> docker-compose.yaml
  echo "    env_file:" >> docker-compose.yaml
  echo "      - .env" >> docker-compose.yaml
  echo "" >> docker-compose.yaml
  echo "  wordpress:" >> docker-compose.yaml
  echo "    depends_on:" >> docker-compose.yaml
  echo "      - db" >> docker-compose.yaml
  echo "    image: wordpress:${wp_version}${php_version}" >> docker-compose.yaml
  echo "    restart: always" >> docker-compose.yaml
  echo "    ports:" >> docker-compose.yaml
  echo '      - 80:80' >> docker-compose.yaml
  echo "    environment:" >> docker-compose.yaml
  # shellcheck disable=SC2016
  echo '      WORDPRESS_DB_HOST: ${WORDPRESS_DB_HOST}' >> docker-compose.yaml
  # shellcheck disable=SC2016
  echo '      WORDPRESS_DB_USER: ${WORDPRESS_DB_USER}' >> docker-compose.yaml
  # shellcheck disable=SC2016
  echo '      WORDPRESS_DB_PASSWORD: ${WORDPRESS_DB_PASSWORD}' >> docker-compose.yaml
  # shellcheck disable=SC2016
  echo '      WORDPRESS_DB_NAME: ${WORDPRESS_DB_NAME}' >> docker-compose.yaml
  echo "    env_file:" >> docker-compose.yaml
  echo "      - .env" >> docker-compose.yaml
  echo "    volumes:" >> docker-compose.yaml
  echo "      - './:/var/www/html'" >> docker-compose.yaml
  echo >> docker-compose.yaml
  echo "  phpmyadmin:" >> docker-compose.yaml
  echo "    image: phpmyadmin/phpmyadmin" >> docker-compose.yaml
  echo "    restart: always" >> docker-compose.yaml
  echo "    ports:" >> docker-compose.yaml
  echo "      - '8080:80'" >> docker-compose.yaml
  echo "    environment:" >> docker-compose.yaml
  # shellcheck disable=SC2016
  echo '      PMA_HOST: ${PMA_HOST}' >> docker-compose.yaml
  # shellcheck disable=SC2016
  echo '      PMA_USER: ${PMA_USER}' >> docker-compose.yaml
  # shellcheck disable=SC2016
  echo '      PMA_PASSWORD: ${PMA_PASSWORD}' >> docker-compose.yaml
  echo "    env_file:" >> docker-compose.yaml
  echo "      - .env" >> docker-compose.yaml
  echo "volumes:" >> docker-compose.yaml
  echo "  mysql: {}" >> docker-compose.yaml
  clear
  echo
  echo "Project name: ${project_name}"
  echo "WordPress version: ${wp_version}"
  if [[ $php_version == "" ]]; then
    echo "PHP version: latest"
  else
    echo "PHP version: ${php_version}"
  fi
  echo
  echo "Docker Compose file generated successfully!"
  echo
}

#handle_project_directory() {
#  p_name="${project_name// /_}"
#  cd "projects" || exit 1;
#  if [ ! -d "${p_name}" ]; then
#      echo "Creating new project folder..."
#      mkdir "${p_name}"
#      sleep 1
#  else
#    echo "Project directory already exists."
#    read -p "Do you want to overwrite it? (y/N): " overwrite_choice
#    if [[ $overwrite_choice == "y" || $overwrite_choice == "Y" ]]; then
#      rm -rf "${p_name}"
#      mkdir "${p_name}"
#    else
#      clear
#      read -p "Please enter a project name: " new_project_name
#      project_name="${new_project_name// /_}"
#      mkdir "${new_project_name// /_}"
#    fi
#    ls
##    cd "projects" || exit 1
#  fi
#}

generate_doc_com() {
  clear

  read -p "Please enter a project name: " project_name

  if [[ $project_name == "" ]]; then
    echo "Error: Project name cannot be empty."
    read -p "Press Enter to continue..."
  else
    clear
    echo "Generating Docker Compose file for ${project_name}..."
    sleep 2
    generate_docker_compose_file
#    project_name="${project_name// /_}"
#    echo "Generating Docker Compose file for ${project_name}..."
#    mkdir "${project_name}"
#    cd "$project_name" || return
#    generate_env_file
#    print_wp_version_menu
#    handle_wp_version
#    # shellcheck disable=SC2129
#    echo "services:" >> docker-compose.yaml
#    echo "  db:" >> docker-compose.yaml
#    echo "    image: mysql:latest" >> docker-compose.yaml
#    echo "    restart: always" >> docker-compose.yaml
#    echo "    environment:" >> docker-compose.yaml
#    # shellcheck disable=SC2016
#    echo '      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}' >> docker-compose.yaml
#    # shellcheck disable=SC2016
#    echo '      MYSQL_DATABASE: ${MYSQL_DATABASE}' >> docker-compose.yaml
#    # shellcheck disable=SC2016
#    echo '      MYSQL_USER: ${MYSQL_USER}' >> docker-compose.yaml
#    # shellcheck disable=SC2016
#    echo '      MYSQL_PASSWORD: ${MYSQL_PASSWORD}' >> docker-compose.yaml
#    echo "    env_file:" >> docker-compose.yaml
#    echo "      - .env" >> docker-compose.yaml
#    echo "" >> docker-compose.yaml
#    echo "  wordpress:" >> docker-compose.yaml
#    echo "    depends_on:" >> docker-compose.yaml
#    echo "      - db" >> docker-compose.yaml
#    echo "    image: wordpress:${wp_version}${php_version}" >> docker-compose.yaml
#    echo "    restart: always" >> docker-compose.yaml
#    echo "    ports:" >> docker-compose.yaml
#    echo '      - 80:80' >> docker-compose.yaml
#    echo "    environment:" >> docker-compose.yaml
#    # shellcheck disable=SC2016
#    echo '      WORDPRESS_DB_HOST: ${WORDPRESS_DB_HOST}' >> docker-compose.yaml
#    # shellcheck disable=SC2016
#    echo '      WORDPRESS_DB_USER: ${WORDPRESS_DB_USER}' >> docker-compose.yaml
#    # shellcheck disable=SC2016
#    echo '      WORDPRESS_DB_PASSWORD: ${WORDPRESS_DB_PASSWORD}' >> docker-compose.yaml
#    # shellcheck disable=SC2016
#    echo '      WORDPRESS_DB_NAME: ${WORDPRESS_DB_NAME}' >> docker-compose.yaml
#    echo "    env_file:" >> docker-compose.yaml
#    echo "      - .env" >> docker-compose.yaml
#    echo "    volumes:" >> docker-compose.yaml
#    echo "      - './:/var/www/html'" >> docker-compose.yaml
#    echo >> docker-compose.yaml
#    echo "  phpmyadmin:" >> docker-compose.yaml
#    echo "    image: phpmyadmin/phpmyadmin" >> docker-compose.yaml
#    echo "    restart: always" >> docker-compose.yaml
#    echo "    ports:" >> docker-compose.yaml
#    echo "      - '8080:80'" >> docker-compose.yaml
#    echo "    environment:" >> docker-compose.yaml
#    # shellcheck disable=SC2016
#    echo '      PMA_HOST: ${PMA_HOST}' >> docker-compose.yaml
#    # shellcheck disable=SC2016
#    echo '      PMA_USER: ${PMA_USER}' >> docker-compose.yaml
#    # shellcheck disable=SC2016
#    echo '      PMA_PASSWORD: ${PMA_PASSWORD}' >> docker-compose.yaml
#    echo "    env_file:" >> docker-compose.yaml
#    echo "      - .env" >> docker-compose.yaml
#    echo "volumes:" >> docker-compose.yaml
#    echo "  mysql: {}" >> docker-compose.yaml
#    clear
#    echo
#    echo "Project name: ${project_name}"
#    echo "WordPress version: ${wp_version}"
#    if [[ $php_version == "" ]]; then
#      echo "PHP version: latest"
#    else
#      echo "PHP version: ${php_version}"
#    fi
#    echo
#    echo "Docker Compose file generated successfully!"
#    echo
    create_readme
    cd ../..
    # shellcheck disable=SC2162
    read -p "Press Enter to continue..."
  fi
}
