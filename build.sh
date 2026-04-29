#!/bin/sh
# Professional Build - Tool & Lib Migrator

mkdir -p bin core/libs core/tools

# 1. ترجمة الـ API وربطها ديناميكياً (أو ستاتيكياً حسب الرغبة)
printf "[*] Compiling pro-api...\n"
gcc core/tools/api.c -o bin/pro-api

# 2. اكتشاف ونقل المكتبات المطلوبة (Libc Discovery)
printf "[*] Collecting required Shared Libraries...\n"
# هذه الخطوة تبحث عن المكتبات التي يحتاجها pro-api وتنقلها إلى core/libs
ldd bin/pro-api | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' core/libs/ 2>/dev/null

# 3. نقل أدوات core/tools الأخرى
if [ "$(ls -A core/tools)" ]; then
    cp -r core/tools/* bin/ 2>/dev/null
fi

chmod +x bin/* init.sh initram.sh
printf "\033[0;32m[+] Build complete. Libc and dependencies are staged.\033[0m\n"
