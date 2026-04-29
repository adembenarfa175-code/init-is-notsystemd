#!/bin/sh
# Professional Init - The Ultimate Linux PID 1 (Final Production Version)

# 1. تصفير البيئة وفرض المسارات العالمية
export PATH="/var/proinit/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export HOME="/root"

# 2. الألوان (ANSI Colors)
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# 3. دالة معالجة إشارات النظام (Power Management)
# الـ PID 1 يجب أن يستقبل SIGINT و SIGPWR لإغلاق الجهاز بنظافة
handle_shutdown() {
    printf "\n${RED}[!] Shutdown signal received. Cleaning up...${NC}\n"
    # إرسال إشارة للمدير ليتوقف
    pkill -f manager.sh
    # فك تركيب الأقراص لضمان عدم فقدان البيانات
    sync
    umount -a -r
    printf "${GREEN}[+] System Halted.${NC}\n"
    exit 0
}

# ربط الإشارات بالدالة
trap handle_shutdown SIGINT SIGPWR SIGTERM

# 4. تهيئة ملفات النظام الأساسية
printf "${CYAN}[*] Mounting Virtual Filesystems...${NC} "
mount -t proc proc /proc 2>/dev/null
mount -t sysfs sys /sys 2>/dev/null
mount -t devtmpfs dev /dev 2>/dev/null
mount -t tmpfs tmpfs /run 2>/dev/null
printf "[ ${GREEN}OK${NC} ]\n"

# 5. طباعة الشعار (Banner)
if command -v lolcat >/dev/null 2>&1; then
    cat << "BANNER" | lolcat
#######################################################
#   _____           _   _ _   _                       #
#  |  __ \         | \ | | \ | |                      #
#  | |__) | __ ___ |  \| |  \| |                      #
#  |  ___/ '__/ _ \| . ` | . ` |                      #
#  | |   | | | (_) | |\  | |\  |                      #
#  |_|   |_|  \___/|_| \_|_| \_|                      #
#       THE PROFESSIONAL INIT - STABLE 1.0            #
#######################################################
BANNER
else
    printf "${CYAN}--- PROFESSIONAL INIT SYSTEM (STABLE) ---${NC}\n"
fi

# 6. تجهيز قنوات التواصل (API Pipes)
mkdir -p /run/proinit
[ -p /run/proinit/initctl ] || mkfifo /run/proinit/initctl
chmod 666 /run/proinit/initctl

# 7. استدعاء المديـر (Handover)
MANAGER_PATH="/var/proinit/core/manager.sh"
if [ -f "$MANAGER_PATH" ]; then
    printf "${GREEN}[+] Starting Service Manager...${NC}\n"
    sh "$MANAGER_PATH" >> /var/log/proinit.log 2>&1 &
else
    printf "${RED}[!] CRITICAL: Manager missing at $MANAGER_PATH${NC}\n"
    exec /bin/sh
fi

# 8. حلقة تنظيف العمليات اليتيمة (Zombie Reaping)
# نستخدم 'wait' لمنع تراكم العمليات الميتة في الذاكرة
while :; do
    wait >/dev/null 2>&1
    sleep 30
done

