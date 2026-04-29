#!/bin/sh
# Professional Parser Module

parse_service_type() {
    local file=$1
    if grep -q "Type=oneshot" "$file"; then
        echo "oneshot"
    else
        echo "simple"
    fi
}

get_exec_start() {
    grep "ExecStart=" "$1" | cut -d'=' -f2
}
