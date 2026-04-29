#!/bin/sh

# Professional Init - System Installer
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

printf "${BLUE}[*] Installing Professional Init to System Root...${NC}\n"

# 1. إنشاء المسارات المطلوبة
mkdir -p /var/proinit
mkdir -p /var/proinit/services
mkdir -p /var/proinit/services_core
mkdir -p /var/proinit/core
mkdir -p /sbin

# 2. نقل الملفات إلى /var/proinit
printf "[1/3] Deploying components to /var/proinit...\n"
cp -rf ./services/* /var/proinit/services/ 2>/dev/null
cp -rf ./services_core/* /var/proinit/services_core/ 2>/dev/null
cp -rf ./core/* /var/proinit/core/ 2>/dev/null
cp -f ./Makefile ./README.md ./build.sh /var/proinit/ 2>/dev/null

# 3. تثبيت المحرك الأساسي في /sbin/init
printf "[2/3] Linking init.sh to /sbin/init...\n"
cp -f ./init.sh /sbin/init
chmod +x /sbin/init

# 4. ضبط الروابط الرمزية (Symlinks) للأدوات
printf "[3/3] Finalizing system links...\n"
# التأكد من أن pro-api متاح عالمياً
if [ -f "./bin/pro-api" ]; then
    cp ./bin/pro-api /usr/bin/pro-api
    chmod +x /usr/bin/pro-api
fi

printf "${GREEN}[+] Installation Complete!${NC}\n"
printf "${BLUE}Structure:${NC}\n"
printf " - Binaries: /usr/bin/pro-api\n"
printf " - Core Logic: /var/proinit/core\n"
printf " - Services: /var/proinit/services & services_core\n"
printf " - PID 1: /sbin/init\n"
