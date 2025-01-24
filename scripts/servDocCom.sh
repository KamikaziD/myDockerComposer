#!/bin/bash

echo "Hello Service Docker Composer!"

declare -A selected

declare -A services=(
    [1]="postgresQL"
    [2]="redis"
    [3]="pgAdmin"
)

declare -A services=(
    [1]="Authentication"
    [2]="Basic (stdout) Logging"
    [3]="[Elastic] Logging"
    [4]="[Elastic] APM"
    [5]="Demo UI"
    [6]="Relay"
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

build_command() {
    local cmd=" -f docker-compose.override.yaml -f docker-compose.dev.db.yaml"
    if [[ $is_github_deployment == 1 ]]; then
        cmd+=" -f docker-compose.dev.rule.yaml -f docker-compose.dev.yaml"
        for key in "${!addon_files_dev[@]}"; do
            [[ ${selected[$key]} == 1 ]] && cmd+=" -f ${addon_files_dev[$key]}"
        done
    else
        cmd+=" -f docker-compose.rule.yaml -f docker-compose.yaml"
        for key in "${!addon_files[@]}"; do
            [[ ${selected[$key]} == 1 ]] && cmd+=" -f ${addon_files[$key]}"
        done
    fi
    echo "$cmd"
}

apply_services_config() {
    local confirm=""
    local compose_files=$(build_command)
    echo
    echo "Command to run: docker compose$compose_files -p tazama up -d"
    read -p "Press (e) to execute, (q) to quit or any other key to go back: " confirm
    echo
    if [[ -z $confirm || $confirm == "e" ]]; then
        docker compose$compose_files -p tazama up -d --remove-orphans
        exit 0
    elif [[ $confirm == "q" ]]; then
        exit 0
    fi
}

print_services_menu

while true; do
    echo "Apply current selection (a), Toggle addon (1-6) or quit (q)"
    read -p "Enter your choice: " choice

    case "$choice" in
    [1-6])
        if [[ ${selected[$choice]} == 1 ]]; then
            selected[$choice]=0
        else
            selected[$choice]=1
        fi
        ;;
    A | a)
        apply_services_config
        ;;
    Q | q)
        exit 0
        ;;
    *)
        echo "Invalid option. Press any key to continue..."
        read -n 1
        ;;
    esac
    print_services_menu
done