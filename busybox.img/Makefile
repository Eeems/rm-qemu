SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

TAG := ghcr.io/eeems/rm-qemu-artifact:busybox.img
OBJ := $(shell ../tools/get-objects)
OUTPUTS := busybox.img

ifndef KERNEL
KERNEL := 5.8.18
endif

all: image

image:
	../tools/make-image \
	  ${TAG} \
	  $$($(MAKE) hash) \
	  "--build-arg=KERNEL=${KERNEL}"

define make-target
.PHONY: $1
$1: $2
$2: image
	../tools/get-artifact "${TAG}" $1
endef
$(foreach O,\
	$(OUTPUTS),\
	$(eval $(call make-target, \
		$(O), \
		artifact/$(O) \
	)) \
)

script.img: script
	qemu-img create script.img 1M
	mkfs.vfat script.img
	mcopy -i script.img script ::init

run: busybox.img script.img ../appimage/bin/get-free-port
	$(MAKE) -C ../busybox-kernel KERNEL=${KERNEL} busybox-zImage
	$(MAKE) -C ../rootfs KERNEL=${KERNEL} base.qcow2
	port=$$(../appimage/bin/get-free-port); \
	cpus=$$(nproc); \
	echo "RM_BUSYBOX_PORT=$${port}"; \
	echo "cpus=$${cpus}"; \
	qemu-system-arm \
	  -machine \
	  virt \
	  -smp \
	  cpus=$${cpus} \
	  -m \
	  size=2048 \
	  -kernel \
	  ../busybox-kernel/artifact/busybox-zImage \
	  -initrd \
	  artifact/busybox.img \
	  -append \
	  "quiet" \
	  -device \
	  virtio-net-device,netdev=net0 \
	  -netdev \
	  user,id=net0,hostfwd=tcp::$${RM_BUSYBOX_PORT:-2221}-:22 \
	  -device \
	  virtio-blk-device,drive=hd2 \
	  -drive \
	  if=none,file=../rootfs/artifact/base.qcow2,format=qcow2,readonly=on,id=hd2 \
	  -device \
	  virtio-blk-device,drive=hd1 \
	  -drive \
	  if=none,file=null-co://,format=raw,id=hd1 \
	  -device \
	  virtio-blk-device,drive=hd0 \
	  -drive \
	  if=none,file=null-co://,format=raw,id=hd0 \
	  -serial \
	  mon:stdio \
	  -nographic

test: artifact/busybox.img script.img ../appimage/bin/get-free-port
	$(MAKE) -C ../busybox-kernel KERNEL=${KERNEL} busybox-zImage
	port=$$(../appimage/bin/get-free-port); \
	cpus=$$(nproc); \
	echo "RM_BUSYBOX_PORT=$${port}"; \
	echo "cpus=$${cpus}"; \
	qemu-system-arm \
	  -machine \
	  virt \
	  -smp \
	  cpus=$${cpus} \
	  -m \
	  size=2048 \
	  -kernel \
	  ../busybox-kernel/artifact/busybox-zImage \
	  -initrd \
	  artifact/busybox.img \
	   -device \
	  virtio-net-device,netdev=net0 \
	  -netdev \
	  user,id=net0,hostfwd=tcp::$${RM_BUSYBOX_PORT:-2221}-:22 \
	  -device \
	  virtio-blk-device,drive=hd0 \
	  -drive \
	  if=none,file=script.img,format=raw,id=hd0 \
	  -serial \
	  mon:stdio \
	  -nographic

.SILENT: tag
tag:
	@echo ${TAG}

.SILENT: hash
hash:
	@../tools/get-hash \
	  --single \
	  ${OBJ} \
	  $(get-depends-static-flags)

.SILENT: depends
depends:
	@echo busybox-kernel

.PHONY: \
	all \
	tag \
	hash \
	depends \
	image \
	run \
	test
