# Professional Init - Master Makefile

.PHONY: all build initramfs install clean

all: build initramfs

build:
	@echo "Building API and staging tools..."
	@gcc core/tools/api.c -o bin/pro-api
	@chmod +x build.sh
	@./build.sh

initramfs: build
	@echo "Generating bootable initrd..."
	@chmod +x make_initramfs.sh
	@./make_initramfs.sh

install: build
	@echo "Installing to system root (Requires Root)..."
	@./install.sh

clean:
	@rm -rf bin/* core/libs/* build_tmp/ professional-initrd.img
	@echo "Cleanup finished."
