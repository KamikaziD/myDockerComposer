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
  echo "      - \"3000:3000\"" >> docker-compose.yaml
}

handle_next_js() {
  local cmd="npx create-next-app@latest"
  local answer
  local defaults
  sleep 1
  clear
  echo "Creating Next.js"
  read -p "Use defaults (y/n)? " defaults

  read -p "What is your project Name? " project_name
  cmd+=" ${project_name}"

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
        cmd+=" -no-tailwind"
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
        cmd+=" -no-eslint"
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

  $cmd
  clear
  echo "Next.js Project Created Successfully: ${project_name}"
  sleep 1
  echo "Creating Dockerfile"
  cd "${project_name}" || exit 1
  create_docker_file
  sleep 1
  echo "Creating docker-compose.yaml"
  create_docker_compose
  sleep 2
  run_docker_compose
}

handle_postgres() {
  sleep 2
  clear
  echo "Creating PostgreSQL"
#  create_docker_compose
  # Add logic here
  read -p "Press any key to continue..."
}

handle_pgadmin() {
  sleep 2
  clear
  echo "Creating pgAdmin"
  # Add logic here
  read -p "Press any key to continue..."
}

handle_selected_services() {
  local selected_services=()

  echo "Applying selected Services:"
  for ((i = 1; i <= ${#services[@]}; i++)); do
    if [[ ${selected[$i]} == 1 ]]; then
      if [[ ${services[$i]} == "PostgreSQL" ]]; then
        # Add logic here
        echo "  Service: PostgreSQL"
        handle_postgres
      elif [[ ${services[$i]} == "pgAdmin" ]]; then
        # Add logic here
        echo "  Service: PGAdmin"
        handle_pgadmin
      elif [[ ${services[$i]} == "Redis" ]]; then
        # Add logic here
        echo "  Service: Redis"
      elif [[ ${services[$i]} == "NextJS" ]]; then
        # Add logic here
        echo "  Service: NextJS"
        handle_next_js
      fi
    fi
  done
#  read -p "Press any key to continue..."
}

while true; do
  print_services_menu

  read -p "Select services  to add (1-4) or ('c' to continue 'q' to quit): " choice

  if [[ $choice == 'q' ]]; then
    echo "Exiting..."
    break
  fi

  if [[ $choice == 'c' ]]; then
    echo "Creating services..."
    handle_selected_services
#    break
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