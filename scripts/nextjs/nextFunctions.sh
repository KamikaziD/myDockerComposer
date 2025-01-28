#!/bin/bash

. ./scripts/common/functions.sh

declare -A selected=([1]=1 [2]=0 [3]=0 [4]=0)

declare -A @project_name
declare -A @typescript=1
declare -A @tailwind=1
declare -A @eslint=1
declare -A @npm=1


declare -A services=(
    [1]="NextJS"
    [2]="PostgreSQL"
    [3]="pgAdmin"
    [4]="Redis"
)

print_services_menu() {
    clear
    echo "Enable optional docker configuration addons:"
    for ((i = 1; i <= ${#services[@]}; i++)); do
        if [[ ${selected[$i]} == 1 ]]; then
            echo "$i. [X] ${services[$i]}"
        else
            echo "$i. [ ] ${services[$i]}"
        fi
    done
    echo
}

create_docker_file() {
  # shellcheck disable=SC2129
  echo "FROM node:22-bookworm-slim AS base" >> Dockerfile
  echo "WORKDIR /app" >> Dockerfile
  echo "COPY package*.json ./" >> Dockerfile
  echo "EXPOSE 3000" >> Dockerfile
  echo "" >> Dockerfile
  echo "FROM base AS builder" >> Dockerfile
  echo "COPY . ." >> Dockerfile
  echo "RUN npm run build" >> Dockerfile
  echo "" >> Dockerfile
  echo "" >> Dockerfile
#  if [[ "${npm}" == 1 ]]; then
#    echo "COPY package-lock.json ./" >> Dockerfile
#  else
#    echo "COPY yarn*.lock ./" >> Dockerfile
#  fi

  # shellcheck disable=SC2129
  echo "FROM base AS dev" >> Dockerfile
  echo "ENV NODE_ENV=development" >> Dockerfile
  echo "RUN npm install" >> Dockerfile
  echo "COPY . ." >> Dockerfile
  echo "CMD npm run dev" >> Dockerfile

  echo "Dockerfile created"
  sleep 2
}

generate_env_file() {
  local project_name
  if [ -z "$1" ]; then
    echo "Error: Project Name is required."
    exit 1
  else
    echo "Project Name: $1"
    project_name=$1
  fi
  if [ -z "$2" ]; then
    echo "Error: Project Name is required."
    exit 1
  else
    echo "Project Name: $1"
    project_name=$1
  fi
}

run_docker_compose() {
  local build_tag_cmd="docker build -t ui-app ."
#  local build_cmd="COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose build"
  local run_cmd="docker compose up -d"
  echo "Build and Tagging image"
  $build_tag_cmd
  sleep 2
  echo "Running Docker Compose Build"
  COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker compose build
  sleep 2
  echo "Running Docker Compose"
  $run_cmd
  sleep 2
  docker ps
  read -p "Press enter to continue..."
}


create_docker_compose() {
  # ----------> Add IF statements based on OPTIONS SELECTED

  # shellcheck disable=SC2129
  echo "services:" >> docker-compose.yaml
  echo "  app:" >> docker-compose.yaml
  echo "    container_name: ui-app" >> docker-compose.yaml
  echo "    image: ui-app" >> docker-compose.yaml
  echo "    build:" >> docker-compose.yaml
  echo "      context: ./" >> docker-compose.yaml
  echo "      target: dev" >> docker-compose.yaml
  echo "      dockerfile: Dockerfile" >> docker-compose.yaml
  echo "    volumes:" >> docker-compose.yaml
  echo "      - .:/app" >> docker-compose.yaml
  echo "      - /app/node_modules" >> docker-compose.yaml
  echo "      - /app/.next" >> docker-compose.yaml
  echo "    ports:" >> docker-compose.yaml
  # shellcheck disable=SC2016
  echo '      - ${PORT}:${PORT}' >> docker-compose.yaml
  if [[ ${selected[2]} == 1 || ${selected[3]} == 1 || ${selected[4]} == 1 ]]; then
    # shellcheck disable=SC2129
    echo "    depends_on:" >> docker-compose.yaml
  fi
  if [[ ${selected[2]} == 1 ]]; then
    echo "      db:" >> docker-compose.yaml
    echo "        condition: service_healthy" >> docker-compose.yaml
  fi
  if [[ ${selected[4]} == 1 ]]; then
    echo "      redis:" >> docker-compose.yaml
    echo "        condition: service_healthy" >> docker-compose.yaml
  fi
  echo "" >> docker-compose.yaml

  if [[ ${selected[2]} == 1 ]]; then
    # shellcheck disable=SC2129
    echo "  db:" >> docker-compose.yaml
    echo "    image: postgres:16-alpine" >> docker-compose.yaml
    echo "    restart: always" >> docker-compose.yaml
    echo "    ports:" >> docker-compose.yaml
    # shellcheck disable=SC2016
    echo '      - ${POSTGRES_PORT}:${POSTGRES_PORT}' >> docker-compose.yaml
    echo "    environment:" >> docker-compose.yaml
    # shellcheck disable=SC2016
    echo '      POSTGRES_USER: ${POSTGRES_USER}' >> docker-compose.yaml
    # shellcheck disable=SC2016
    echo '      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}' >> docker-compose.yaml
    # shellcheck disable=SC2016
    echo '      POSTGRES_DB: ${POSTGRES_DB}' >> docker-compose.yaml
    # shellcheck disable=SC2016
    echo '      POSTGRES_PORT: ${POSTGRES_PORT}' >> docker-compose.yaml
    echo "    env_file:" >> docker-compose.yaml
    echo "      - .env" >> docker-compose.yaml
    echo "    volumes:" >> docker-compose.yaml
    echo "      - postgres_data:/var/lib/postgresql/data/" >> docker-compose.yaml
    echo "    healthcheck:" >> docker-compose.yaml
    echo "      test: [ 'CMD-SHELL', 'pg_isready -U admin -d ${project_name// /_}_db' ]" >> docker-compose.yaml
    echo "      interval: 1s" >> docker-compose.yaml
    echo "      timeout: 5s" >> docker-compose.yaml
    echo "      retries: 5" >> docker-compose.yaml
    echo "" >> docker-compose.yaml
  fi

  if [[ ${selected[3]} == 1 ]]; then
    # shellcheck disable=SC2129
    echo "  pgadmin:" >> docker-compose.yaml
    echo "    image: dpage/pgadmin4" >> docker-compose.yaml
    echo "    container_name: pgadmin4_container" >> docker-compose.yaml
    echo "    restart: always" >> docker-compose.yaml
    echo "    ports:" >> docker-compose.yaml
    # shellcheck disable=SC2016
    echo '      - ${PGADMIN_PORT}:80' >> docker-compose.yaml
    echo "    environment:" >> docker-compose.yaml
    # shellcheck disable=SC2016
    echo '      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL}' >> docker-compose.yaml
    # shellcheck disable=SC2016
    echo '      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD}' >> docker-compose.yaml
    echo "    volumes:" >> docker-compose.yaml
    echo "      - pgadmin_data:/var/lib/pgadmin" >> docker-compose.yaml
    echo ""
  fi

  if [[ ${selected[4]} == 1 ]]; then
    # shellcheck disable=SC2129
    echo "  redis:" >> docker-compose.yaml
    echo "    image: redis:6-alpine" >> docker-compose.yaml
    echo "    restart: always" >> docker-compose.yaml
    echo "    ports:" >> docker-compose.yaml
    # shellcheck disable=SC2016
    echo '      - ${REDIS_PORT}:${REDIS_PORT}' >> docker-compose.yaml
    echo "    environment:" >> docker-compose.yaml
    # shellcheck disable=SC2016
    echo '      REDIS_PASSWORD: ${REDIS_PASSWORD}' >> docker-compose.yaml
    # shellcheck disable=SC2016
    echo '      REDIS_PORT: ${REDIS_PORT}' >> docker-compose.yaml
    echo "    env_file:" >> docker-compose.yaml
    echo "      - .env" >> docker-compose.yaml
    # shellcheck disable=SC2016
    echo '    command: redis-server --save 20 1 --loglevel warning --requirepass ${REDIS_PASSWORD}' >> docker-compose.yaml
    echo "    volumes:" >> docker-compose.yaml
    echo "      - redis_data:/data" >> docker-compose.yaml
    echo "    healthcheck:" >> docker-compose.yaml
    echo '      test: [ "CMD", "redis-cli", "--raw", "incr", "ping" ]' >> docker-compose.yaml
    echo "      interval: 1s" >> docker-compose.yaml
    echo "      timeout: 5s" >> docker-compose.yaml
    echo "      retries: 5" >> docker-compose.yaml
    echo "" >> docker-compose.yaml
  fi


  echo "volumes:" >> docker-compose.yaml
  echo "" >> docker-compose.yaml

  if [[ ${selected[2]} == 1 ]]; then
    find_function "volumes:" "postgres_data" "docker-compose.yaml" "."
  fi

  if [[ ${selected[3]} == 1 ]]; then
    find_function "volumes:" "pgadmin_data" "docker-compose.yaml" "."
  fi

  if [[ ${selected[4]} == 1 ]]; then
    find_function "volumes:" "redis_data" "docker-compose.yaml" "."
  fi
}

create_env_file() {
  local app_name
  if [ -z "$1" ]; then
    echo "Error: Application Name is required."
    exit 1
  else
    app_name="$1"
#    echo "Application Name: $1"

    # shellcheck disable=SC2129
    if [[ ${selected[1]} == 1 ]]; then
      echo "# NEXTJS" >> .env
      echo "PORT=3000" >> .env
      echo "" >> .env
    fi
    if [[ ${selected[2]} == 1 ]]; then
      # shellcheck disable=SC2129
      echo "# POSTGRESQL" >> .env
      echo "POSTGRES_HOST=db" >> .env
      echo "POSTGRES_USER=admin" >> .env
      echo "POSTGRES_PASSWORD=postgres" >> .env
      echo "POSTGRES_DB=${app_name}_db" >> .env
      echo "POSTGRES_PORT=5432" >> .env
      # shellcheck disable=SC2016
      echo 'DATABASE_URL=jdbc:postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB' >> .env
      echo "" >> .env
    fi
    if [[ ${selected[3]} == 1 ]]; then
      # shellcheck disable=SC2129
      echo "# PGADMIN" >> .env
      echo "PGADMIN_PORT=8888" >> .env
      echo "PGADMIN_DEFAULT_EMAIL=admin@example.com" >> .env
      echo "PGADMIN_DEFAULT_PASSWORD=password" >> .env
      echo "" >> .env
    fi
    if [[ ${selected[4]} == 1 ]]; then
      # shellcheck disable=SC2129
      echo "# REDIS" >> .env
      echo "REDIS_HOST=redis" >> .env
      echo "REDIS_PORT=6379" >> .env
      echo "REDIS_PASSWORD=redis" >> .env
      echo "" >> .env
    fi
  fi
}

handle_next_js() {
  local cmd="npx create-next-app@latest"
  local answer
  local defaults
  local p_name
  sleep 1
  clear
  echo "Creating Next.js"
  read -p "Use defaults (y/n)? " defaults

  read -p "What is your project Name? " project_name
  p_name="${project_name// /_}"
  cmd+=" ${project_name// /_}"

  if [[ ${defaults} == "y" ]]; then
    echo "Defaults used..."
    cmd+=" -ts"
    typescript=1
    cmd+=" --eslint"
    eslint=1
    cmd+=" --tailwind"
    tailwind=1
    cmd+=" --use-npm"
    npm=1
    echo "${cmd}"
  else
    while true; do
      read -p "Typescript (t) or Javascript (j)? " answer
      if [[ ${answer} == "t" ]]; then
        cmd+=" -ts"
        typescript=1
        break
      elif [[ ${answer} == "j" ]]; then
        cmd+=" -js"
        typescript=0
        break
      fi
    done

    while true; do
      read -p "Use Tailwind (y/n)? " answer
      if [[ ${answer} == "y" ]]; then
        cmd+=" --tailwind"
        tailwind=1
        break
      elif [[ ${answer} == "n" ]]; then
        cmd+=" --no-tailwind"
        tailwind=0
        break
      fi
    done

    while true; do
      read -p "npm (n) or yarn (y)? " answer
      if [[ ${answer} == "n" ]]; then
        cmd+=" --use-npm"
        npm=1
        break
      elif [[ ${answer} == "y" ]]; then
        cmd+=" --use-yarn"
        npm=0
        break
      fi
    done

    while true; do
      read -p "Use ES-Lint (y/n)? " answer
      if [[ ${answer} == "y" ]]; then
        cmd+=" --eslint"
        eslint=1
        break
      elif [[ ${answer} == "n" ]]; then
        cmd+=" --no-eslint"
        eslint=0
        break
      fi
    done
  fi
  clear
  echo "Creating Next.js Project: ${project_name}"

  if [[ ${typescript} == 1 ]]; then
      echo "Typescript: Yes"
  else
      echo "Typescript: No"
  fi

  if [[ ${npm} == 1 ]]; then
      echo "Package Manager: npm"
  else
      echo "Package Manager: yarn"
  fi
  if [[ ${eslint} == 1 ]]; then
      echo "Linting: Yes"
  else
      echo "Linting: No"
  fi

  if [[ ${tailwind} == 1 ]]; then
      echo "Tailwind: Yes"
  else
      echo "Tailwind: No"
  fi
  echo
  echo "Cmd: ${cmd}"
  echo
  # Add logic here
  cmd+=" --yes"
  read -p "Press any key to continue..."

# HERE ------------------------------------------################################
  echo "Creating Dockerfile"
  handle_project_directory "${project_name}"
  $cmd
  sleep 1
  clear


  cd "${p_name}" || echo "Something went wrong. Line 232"
  create_env_file "${p_name}"
  create_docker_file
  sleep 1
  echo "Creating docker-compose.yaml"
  create_docker_compose
  echo "Testing the insert line..."
  cat docker-compose.yaml

  read -p "Press enter to continue..."

  echo "Next.js Project Created Successfully: ${project_name}"
  sleep 1
  clear
  cd ../..

  echo "Docker Compose File Created: docker-compose.yaml"
  echo "Environment File Created:.env"
  echo "Dockerfile Created: Dockerfile"
  echo
  sleep 1
  echo "To build the NextJS image run the following:"
  echo " - 'COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker compose build'"
  echo
  sleep 1
  echo "To start the containers, run the following:"
  echo " - 'docker compose up -d'"
  echo
  sleep 1
  echo "To stop the containers, run the following:"
  echo " - 'docker compose down --remove-orphans'"
  echo
  read -p "Press enter to continue"

#  run_docker_compose
}

handle_postgres() {
  sleep 2
  clear
  echo "Creating PostgreSQL"
#  create_docker_compose
  # Add logic here
  read -p "Press enter to continue..."
}

handle_pgadmin() {
  sleep 2
  clear
  echo "Creating pgAdmin"
  # Add logic here
  read -p "Press enter to continue..."
}

handle_selected_services() {

  echo "Applying selected Services:"
  handle_next_js
#  for ((i = 1; i <= ${#services[@]}; i++)); do
#    if [[ ${selected[$i]} == 1 ]]; then
#      handle_next_js
#      echo "  Service: NextJS"
#      if [[ ${services[$i]} == "PostgreSQL" ]]; then
#        # Add logic here
#        echo "  Service: PostgreSQL"
#        handle_postgres
#      elif [[ ${services[$i]} == "pgAdmin" ]]; then
#        # Add logic here
#        echo "  Service: PGAdmin"
#        handle_pgadmin
#      elif [[ ${services[$i]} == "Redis" ]]; then
#        # Add logic here
#        echo "  Service: Redis"
#      elif [[ ${services[$i]} == "NextJS" ]]; then
#        # Add logic here
#        echo "  Service: NextJS"
#        handle_next_js
#      fi
#    fi
#  done
#  read -p "Press any key to continue..."
}

while true; do
  print_services_menu

  read -p "Select services  to add (1-4) or ('e' to execute 'b' back): " choice

  if [[ $choice == 'b' || $choice == 'B' ]]; then
#    echo "Exiting..."
    break
  fi

  if [[ $choice == 'e' || $choice == 'E' ]]; then
    echo "Creating services..."
    handle_selected_services
  fi

  if [[ $choice =~ ^[1-4]$ ]]; then
    if [[ ${selected[$choice]} == 1 ]]; then
      selected[$choice]=0
      echo "Deselected ${services[$choice]}"
    else
      selected[$choice]=1
      echo "Selected ${services[$choice]}"
    fi
  fi
#  handle_selected_services
done