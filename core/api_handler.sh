#!/bin/sh
# Professional API Handler

handle_api_command() {
    local cmd=$1
    local target=$2
    
    case "$cmd" in
        "start") run_service "services/$target" ;;
        "stop")  kill $(cat "/run/$target.pid") ;;
        "status") check_health "$target" && echo "Running" || echo "Stopped" ;;
    esac
}
