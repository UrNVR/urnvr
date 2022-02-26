.PHONY: all clean buildroot-defconfig buildroot-menuconfig buildroot-savedefconfig busybox-menuconfig kernel-defconfig kernel-menuconfig kernel-savedefconfig initramfs kernel kernel-modules

$(info $(shell mkdir -p out/buildroot out/kernel out/modules))

OPTS_BUILDROOT = -C src/buildroot O=../../out/buildroot BR2_DEFCONFIG=../urnvr-init/defconfig

OPTS_KERNEL = -C src/unvr-kernel O=../../out/kernel

EXPORT_KERNEL = ARCH=arm64 CROSS_COMPILE=../../out/buildroot/host/bin/aarch64-linux- INSTALL_MOD_PATH=../../out


KERNEL_VERSION = $(shell grep -oP '^VERSION\s*=\s*\K[0-9]+' src/unvr-kernel/Makefile)
KERNEL_PATCHLEVEL = $(shell grep -oP '^PATCHLEVEL\s*=\s*\K[0-9]+' src/unvr-kernel/Makefile)
KERNEL_SUBLEVEL = $(shell grep -oP '^SUBLEVEL\s*=\s*\K[0-9]+' src/unvr-kernel/Makefile)
KERNEL_LOCALVERSION = $(shell grep -oP '^CONFIG_LOCALVERSION\s*=\s*"\K[^"]*' out/kernel/.config)
KERNEL_VSTRING = $(KERNEL_VERSION).$(KERNEL_PATCHLEVEL).$(KERNEL_SUBLEVEL)$(KERNEL_LOCALVERSION)

all: kernel kernel-modules

clean:
	@make -C src/urnvr-init clean
	@rm -r out

buildroot-defconfig: out/buildroot/.config

buildroot-menuconfig:
	@make $(OPTS_BUILDROOT) menuconfig

buildroot-savedefconfig:
	@make $(OPTS_BUILDROOT) savedefconfig

busybox-menuconfig:
	@make $(OPTS_BUILDROOT) busybox-menuconfig

kernel-defconfig: out/kernel/.config

kernel-menuconfig:
	@$(EXPORT_KERNEL) make $(OPTS_KERNEL) menuconfig

kernel-savedefconfig:
	@$(EXPORT_KERNEL) make $(OPTS_KERNEL) savedefconfig

initramfs: out/buildroot/images/rootfs.cpio.gz

kernel: out/uImage

kernel-modules:
	@$(EXPORT_KERNEL) make $(OPTS_KERNEL) modules_install

out/buildroot/images/rootfs.cpio.gz: out/buildroot/.config
	@make -C src/urnvr-init
	@make $(OPTS_BUILDROOT)

out/buildroot/.config:
	@make $(OPTS_BUILDROOT) defconfig

out/kernel/arch/arm64/boot/Image.gz: out/kernel/.config out/buildroot/images/rootfs.cpio.gz
	@$(EXPORT_KERNEL) make $(OPTS_KERNEL)

out/uImage: out/kernel/arch/arm64/boot/Image.gz
	@out/buildroot/host/bin/mkimage -A arm64 -O linux -T kernel -C none -a 0x4080000 -e 0x4080000 -n "$(KERNEL_VSTRING)" -C gzip -d out/kernel/arch/arm64/boot/Image.gz out/uImage

out/kernel/.config:
	@cp src/kernel-defconfig out/kernel/.config

help:
	@$(EXPORT_KERNEL) make $(OPTS_KERNEL) help

