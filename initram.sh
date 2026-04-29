#!/bin/sh

# Professional Initramfs - Stage 1
# الهدف: تجهيز البيئة وتركيب القرص الحقيقي

export PATH=/usr/bin:/usr/sbin:/bin:/sbin

# 1. تركيب الملفات الأساسية للذاكرة
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t devtmpfs dev /dev

printf "\033[0;36m[Initramfs] Professional Boot Stage 1...\033[0m\n"

# 2. البحث عن القرص الصلب الحقيقي (Root Partition)
# سنفترض هنا أن القرص هو /dev/sda1 (يمكن تغييره حسب النظام)
ROOT_DEV="/dev/sda1"

printf "[*] Waiting for root device %s...\n" "$ROOT_DEV"
# انتظام بسيط للتأكد من استجابة القرص
sleep 2 

# 3. تركيب القرص الحقيقي في مجلد مؤقت
mkdir -p /newroot
mount "$ROOT_DEV" /newroot

if [ $? -eq 0 ]; then
    printf "\033[0;32m[+] Root filesystem mounted successfully.\033[0m\n"
    
    # 4. الانتقال العظيم (The Great Switch)
    # نقوم بنقل الملفات الوهمية للمجلد الجديد لضمان استمرارية النظام
    mount --move /proc /newroot/proc
    mount --move /sys /newroot/sys
    mount --move /dev /newroot/dev
    
    printf "[*] Switching root to Professional Init...\n"
    
    # الانتقال لملف init.sh الذي برمجناه سابقاً على القرص الصلب
    exec switch_root /newroot /sbin/init
else
    printf "\033[0;31m[!] EMERGENCY: Could not mount root device!\033[0m\n"
    exec /bin/sh
fi
