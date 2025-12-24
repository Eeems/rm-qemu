KERNEL_TAG ?= RM1XX_5.4.70_v1.6.2
KERNEL ?= 5.4.70
VERSION ?= v1.6.2
TAG := ghcr.io/eeems/rm-qemu-artifact:kernel-${KERNEL_TAG}
OUTPUTS := zImage qemu.dtb

BUILD_ARGS := "KERNEL=$(KERNEL)"
BUILD_ARGS += "KERNEL_TAG=$(KERNEL_TAG)"
BUILD_ARGS += "VERSION=$(VERSION)"


CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.6.2 VERSION=v1.6.2"
CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.6.1 VERSION=v1.6.1"
CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.3.4 VERSION=v1.5.1"
CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.3.4 VERSION=v1.4.1"
CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.3.4 VERSION=v1.3.4"
CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.3.3 VERSION=v1.3.3"
CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.2.6 VERSION=v1.2.6"
CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.2.5 VERSION=v1.2.5"
CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.2.4 VERSION=v1.2.4"
# CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.2.3 VERSION=v1.2.3"
CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.2.2 VERSION=v1.2.2"
CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.2.1 VERSION=v1.2.1"
# CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.2.0 VERSION=v1.2.0"
CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.1.0 VERSION=v1.1.5"
# CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.1.0 VERSION=v1.1.0"
# CONFIGS += "KERNEL=5.4.70 KERNEL_TAG=RM1XX_5.4.70_v1.0.0 VERSION=v1.0.0"

TEST_DEPENDS += busybox-initrd qemu-system-arm

include ../target.mk

ARTIFACTDIR := artifact/${KERNEL}_${VERSION}

$(OUTPUTS):: %: artifact/%
	mkdir -p $(ARTIFACTDIR)
	mv artifact/$* $(ARTIFACTDIR)/

test:: zImage qemu.dtb
	../qemu-system-arm/artifact/qemu-system-arm \
	  -machine \
	  mcimx7d-sabre \
	  -cpu \
	  cortex-a9 \
	  -smp \
	  2 \
	  -m \
	  2048 \
	  -kernel \
	  $(ARTIFACTDIR)/zImage \
	  -dtb \
	  $(ARTIFACTDIR)/qemu.dtb \
	  -serial \
	  mon:stdio \
	  -nographic \
	  -initrd \
	  ../busybox-initrd/artifact/busybox.img \
	  -append \
	  "earlycon=ttymxc0 console=ttymxc0 init=/init -- uname -a"

.PHONY: run
run: zImage qemu.dtb
	../qemu-system-arm/artifact/qemu-system-arm \
	  -machine \
	  mcimx7d-sabre \
	  -cpu \
	  cortex-a9 \
	  -smp \
	  2 \
	  -m \
	  2048 \
	  -kernel \
	  $(ARTIFACTDIR)/zImage \
	  -dtb \
	  $(ARTIFACTDIR)/qemu.dtb \
	  -serial \
	  mon:stdio \
	  -nographic \
	  -initrd \
	  ../busybox-initrd/artifact/busybox.img \
	  -append \
	  "earlycon=ttymxc0 console=ttymxc0 init=/init"
