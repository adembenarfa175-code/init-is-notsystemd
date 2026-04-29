#!/bin/sh

# Professional Init - The Ultimate Linux PID 1
# Targeted at: Native Linux Root Filesystem (Non-Termux)

# 1. تصفير البيئة وفرض المسارات العالمية
export PATH="/var/proinit/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export HOME="/root"

# 2. تهيئة الواجهة الرسومية (ANSI Colors)
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# 3. الربط الحيوي للمكتبات (Dynamic Linking Support)
# ربط مكتبات النظام بالمشروع لضمان عمل كافة الأدوات الديناميكية
mkdir -p /lib /lib64 /usr/lib /var/proinit/core/libs
export LD_LIBRARY_PATH="/lib:/usr/lib:/var/proinit/core/libs"

# 4. طباعة شعار النظام (Professional Banner)
cat << "BANNER" | lolcat
#######################################################
#   _____           _   _ _   _                       #
#  |  __ \         | \ | | \ | |                      #
#  | |__) | __ ___ |  \| |  \| |                      #
#  |  ___/ '__/ _ \| . ` | . ` |                      #
#  | |   | | | (_) | |\  | |\  |                      #
#  |_|   |_|  \___/|_| \_|_| \_|                      #
#                                                     #
#       THE PROFESSIONAL INIT - NATIVE LINUX          #
#######################################################
BANNER
else
    printf "${CYAN}Professional Init System Starting on Native Linux...${NC}\n"
fi

# 5. تهيئة الـ Kernel Filesystems (مهم جداً للـ PID 1)
printf "[*] Mounting Virtual Filesystems... "
mount -t proc proc /proc 2>/dev/null
mount -t sysfs sys /sys 2>/dev/null
mount -t devtmpfs dev /dev 2>/dev/null
mount -t tmpfs tmpfs /run 2>/dev/null
printf "[ ${GREEN}OK${NC} ]\n"

# 6. إنشاء أنابيب التحكم والأمان (Secure API Control)
mkdir -p /run/proinit
[ -p /run/proinit/initctl ] || mkfifo /run/proinit/initctl
chmod 600 /run/proinit/initctl

# حماية الخدمات: لا أحد ينفذها إلا المدير
chmod 700 /var/proinit/services/*/run 2>/dev/null
chmod 700 /var/proinit/services_core/*/run 2>/dev/null

# 7. استدعاء المديـر (Manager) مع صلاحيات PID 1
if [ -f "/var/proinit/core/manager.sh" ]; then
    printf "${GREEN}[+] Handing over to Service Manager (Universal Mode)${NC}\n"
    # تشغيل المدير في الخلفية مع توجيه الأخطاء لسجل النظام
    sh /var/proinit/core/manager.sh >> /var/log/proinit.log 2>&1 &
else
    printf "${RED}[!] CRITICAL: Manager not found at /var/proinit/core/manager.sh${NC}\n"
    printf "${CYAN}[*] Dropping to Emergency Shell (Maintenance Mode)...${NC}\n"
    exec /bin/sh
fi

# 8. الحلقة اللانهائية لمنع Kernel Panic
# الـ PID 1 لا يجب أن يموت أبداً
while :; do
    # تنظيف العمليات اليتيمة (Zombie Reaping) إذا لم يقم المفسر بذلك
    wait >/dev/null 2>&1
    sleep 3600
done
