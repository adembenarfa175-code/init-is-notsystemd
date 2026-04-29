#!/bin/bash

# Professional Init Manager - The "Everything-Support" Logic
# Target Environment: Native Linux Root System (/var/proinit)

# 1. تعريف المسارات الثابتة للنظام
CORE_SERVICES="/var/proinit/services_core"
EXTRA_SERVICES="/var/proinit/services"
CONTROL_PIPE="/run/proinit/initctl"
LOG_FILE="/var/log/proinit.log"

# الألوان الاحترافية
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# دالة التسجيل في سجل النظام
log() {
    printf "${GREEN}[$(date +%T)]${NC} $1\n"
    printf "[$(date +%T)] $1\n" >> "$LOG_FILE"
}

# --- محركات التشغيل (Service Engines) ---

# تشغيل وإعادة تشغيل خدمات Runit
spawn_runit() {
    local name=$1
    local path=$2
    (
        while true; do
            log "${CYAN}Launching Runit Service: $name${NC}"
            # تشغيل السكريبت في جلسة منفصلة
            sh "$path/run" >> "$LOG_FILE" 2>&1
            log "${RED}Service $name crashed/exited. Restarting...${NC}"
            
            # محاولة قراءة تأخير إعادة التشغيل من ملف الإعدادات
            DELAY=5
            [ -f "$path/configure.service" ] && DELAY=$(grep "RestartSec=" "$path/configure.service" | cut -d'=' -f2)
            sleep ${DELAY:-5}
        done
    ) &
}

# مفسر وتشغيل وحدات Systemd (.service)
spawn_systemd() {
    local name=$1
    local conf=$2
    (
        while true; do
            # استخراج الأوامر والمتغيرات من ملف الـ INI
            EXEC_START=$(grep "^ExecStart=" "$conf" | cut -d'=' -f2-)
            EXEC_USER=$(grep "^User=" "$conf" | cut -d'=' -f2)
            RESTART_SEC=$(grep "^RestartSec=" "$conf" | cut -d'=' -f2)
            
            if [ -z "$EXEC_START" ]; then
                log "${RED}Error: ExecStart missing in $name${NC}"
                break
            fi

            log "${YELLOW}Parsing Systemd Unit: $name${NC}"
            
            # تنفيذ الأمر كمستخدم معين إذا طلب الملف ذلك
            if [ -z "$EXEC_USER" ]; then
                eval "$EXEC_START" >> "$LOG_FILE" 2>&1
            else
                su -s /bin/sh -c "$EXEC_START" "$EXEC_USER" >> "$LOG_FILE" 2>&1
            fi

            log "${RED}Systemd Unit $name stopped. Respawning in ${RESTART_SEC:-3}s...${NC}"
            sleep ${RESTART_SEC:-3}
        done
    ) &
}

# --- معالج أوامر الـ API (The Control Center) ---

handle_api() {
    local raw_cmd=$1
    local action=$(echo "$raw_cmd" | cut -d':' -f1)
    local target=$(echo "$raw_cmd" | cut -d':' -f2)

    case "$action" in
        start)
            log "API: Explicit start requested for $target"
            if [ -d "$EXTRA_SERVICES/$target" ]; then
                spawn_runit "$target" "$EXTRA_SERVICES/$target"
            fi
            ;;
        stop)
            log "API: Killing process $target"
            pkill -f "$target"
            ;;
        restart)
            log "API: Restarting $target"
            pkill -f "$target"
            # سيقوم الـ Loop بإعادة تشغيله تلقائياً
            ;;
        status)
            if pgrep -f "$target" > /dev/null; then
                printf "ACTIVE\n" > "/run/proinit/$target.status"
            else
                printf "INACTIVE\n" > "/run/proinit/$target.status"
            fi
            ;;
    esac
}

# --- تسلسل الإقلاع (The Boot Sequence) ---

# المرحلة 1: خدمات النظام الحرجة (Core - OneShot)
# هذه الخدمات لا يعاد تشغيلها لأنها تهيئ النظام فقط
log "Phase 1: Bootstrapping Professional Core Services..."
CORE_ORDER="env core-fs dev-nodes kernel-logs mount-all modules udev-daemon path-merger logger"

for svc in $CORE_ORDER; do
    if [ -d "$CORE_SERVICES/$svc" ]; then
        log "Initializing Core Component: $svc"
        sh "$CORE_SERVICES/$svc/run" >> "$LOG_FILE" 2>&1
    else
        log "${YELLOW}Warning: Core service $svc not found, skipping...${NC}"
    fi
done

# المرحلة 2: خدمات التوافقية (Compatibility Stage)
log "Phase 2: Loading Third-party Services (Runit & Systemd)..."
for svc_dir in "$EXTRA_SERVICES"/*; do
    [ ! -d "$svc_dir" ] && continue
    svc_name=$(basename "$svc_dir")

    if [ -f "$svc_dir/run" ]; then
        spawn_runit "$svc_name" "$svc_dir"
    elif [ -f "$svc_dir/configure.service" ]; then
        spawn_systemd "$svc_name" "$svc_dir/configure.service"
    fi
done

# المرحلة 3: مجمع الاتصالات (The Event Loop)
log "${GREEN}Professional Manager is now PID 1 Master Controller.${NC}"

# التأكد من جاهزية الأنبوب
mkdir -p /run/proinit
[ -p "$CONTROL_PIPE" ] || mkfifo "$CONTROL_PIPE"
chmod 600 "$CONTROL_PIPE"

# الحلقة المستمرة لاستقبال أوامر pro-api
while true; do
    if read cmd < "$CONTROL_PIPE"; then
        handle_api "$cmd"
    fi
done
