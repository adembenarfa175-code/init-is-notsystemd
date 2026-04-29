#!/bin/sh
# تحويل المشروع إلى ملف Initramfs حقيقي

mkdir -p build_tmp
cp initram.sh build_tmp/init
chmod +x build_tmp/init

# نسخ الأدوات الضرورية (يجب أن يكون لديك busybox في bin)
mkdir -p build_tmp/bin build_tmp/dev build_tmp/proc build_tmp/sys build_tmp/newroot
cp bin/busybox build_tmp/bin/ 2>/dev/null || cp $(which busybox) build_tmp/bin/

# إنشاء الروابط للأدوات الأساسية داخل الذاكرة
cd build_tmp/bin
for tool in sh mount printf mkdir sleep switch_root; do
    ln -sf busybox $tool
done
cd ../..

# الضغط بصيغة CPIO (اللغة التي تفهمها النواة)
cd build_tmp
find . | cpio -H newc -o | gzip > ../professional-initrd.img
cd ..

printf "\033[0;32m[+] SUCCESS: professional-initrd.img is ready!\033[0m\n"
rm -rf build_tmp
