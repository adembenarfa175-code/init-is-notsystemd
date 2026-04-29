#!/bin/sh
# Professional Manager - Unified Entry Point

# استيراد الوحدات (Modules)
. ./core/utils.sh
. ./core/parser.sh
. ./core/service_logic.sh
. ./core/api_handler.sh

printf "\033[1;32m[Professional Init] System Manager Started\033[0m\n"

# تشغيل خدمات الـ Core بالترتيب
for svc in $CORE_ORDER; do
    log_info "Booting core service: $svc"
    run_service "services_core/$svc"
done

# الحلقة الرئيسية (The Main Loop)
while true; do
    # فحص الـ API
    if read cmd target < "$API_PIPE"; then
        handle_api_command "$cmd" "$target"
    fi
    
    # فحص صحة الخدمات (Auto-Respawn)
    # (هنا نضع منطق التأكد من أن الخدمات التي يجب أن تعمل ما زالت تعمل)
    sleep 2
done
