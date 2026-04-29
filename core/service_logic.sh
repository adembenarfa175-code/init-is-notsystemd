#!/bin/sh
# Professional Service Logic

run_service() {
    local svc_path=$1
    local name=$(basename "$svc_path")
    
    if [ -f "$svc_path/run" ]; then
        ./"$svc_path/run" &
        echo $! > "/run/$name.pid"
    elif [ -f "$svc_path/configure.service" ]; then
        local exec_cmd=$(get_exec_start "$svc_path/configure.service")
        $exec_cmd &
        echo $! > "/run/$name.pid"
    fi
}

check_health() {
    local pid_file="/run/$1.pid"
    if [ -f "$pid_file" ] && kill -0 $(cat "$pid_file") 2>/dev/null; then
        return 0 # الخدمة تعمل
    else
        return 1 # الخدمة متعطلة
    fi
}
