#!/bin/sh
# Professional Initramfs Bootstrapper - The First PID 1

# 1. المسارات الأساسية في الذاكرة
export PATH="/sbin:/bin:/usr/sbin:/usr/bin"

# 2. تهيئة البيئة الوهمية (ضروري جداً قبل أي حركة)
mount -t proc proc /proc
mount -t sysfs sys /sys
mount -t devtmpfs dev /dev 2>/dev/null || mdev -s # mdev هو بديل udev في busybox

# 3. محاولة العثور على القرص الحقيقي (Root Partition)
# سنبحث عن القرص الذي يحمل اسم "ROOT" أو عبر UUID
printf "\033[0;32m[Professional-Initramfs] Searching for root filesystem...\033[0m\n"

# ننتظر قليلاً ليتعرف النظام على الأقراص (خاصة USB/NVMe)
sleep 2

# ابحث عن القسم (يمكنك تغيير /dev/sda2 حسب جهازك أو استخدام UUID)
ROOT_DEV="/dev/sda2" 

# 4. تركيب القرص الحقيقي في مجلد مؤقت
mkdir -p /mnt/root
if mount "$ROOT_DEV" /mnt/root; then
    printf "[+] Root filesystem mounted successfully.\n"
else
    printf "\033[0;31m[!] CRITICAL: Failed to mount root filesystem on $ROOT_DEV\033[0m\n"
    exec /bin/sh # الدخول في وضع الطوارئ
fi

# 5. نقل الأنظمة الوهمية للقرص الجديد (Move Mounts)
# هذه الخطوة تجعل النظام الحقيقي يرى الـ proc و sys التي بدأناها هنا
mount --move /proc /mnt/root/proc
mount --move /sys /mnt/root/sys
mount --move /dev /mnt/root/dev

# 6. عملية الـ Switch Root (القفزة العظمى)
# هنا يموت هذا السكربت ويولد مشروعك الحقيقي (init.sh) كـ PID 1
printf "\033[0;36m[+] Switching to real root and executing Professional Init...\033[0m\n"

exec switch_root /mnt/root /var/proinit/init.sh

