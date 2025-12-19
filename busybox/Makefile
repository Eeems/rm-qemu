SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

TAG := ghcr.io/eeems/rm-qemu-artifact:busybox
OBJ := $(shell { git ls-files --other --exclude-standard;git ls-files --no-others --exclude-standard; } | uniq | sort)
OUTPUTS := busybox.img

ifndef KERNEL
KERNEL := 5.8.18
endif

all: image

image:
	@set -e;\
	tag=${TAG}; \
	echo "Checking $$tag"; \
	local=$$($(MAKE) hash); \
	image=$$(podman inspect $$tag --format='{{ .Labels.hash }}' 2>/dev/null || skopeo inspect docker://$$tag --format='{{ .Labels.hash }}' || true); \
	if [[ "$$local" != "$$image" ]];then \
	  echo "$$local != $$image"; \
	  podman build \
	    --tag=$$tag \
	    "--build-arg=KERNEL=${KERNEL}" \
	    "--build-arg=HASH=$$local" \
	    .; \
	else \
	  echo "Skipped as hash matches"; \
	fi

${OUTPUTS}: image
	podman run --rm \
	  --volume=$$(pwd):/out \
	  --volume=/bin:/bin:ro \
	  --volume=/usr:/usr:ro \
	  --volume=/lib:/lib:ro \
	  --volume=/lib64:/lib64:ro \
	  --entrypoint=/bin/sh \
	  ${TAG} \
	  -c "cp /$@ /out"

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
	  ../busybox-kernel/busybox-zImage \
	  -initrd \
	  busybox.img \
	  -append \
	  "quiet" \
	  -device \
	  virtio-net-device,netdev=net0 \
	  -netdev \
	  user,id=net0,hostfwd=tcp::$${RM_BUSYBOX_PORT:-2221}-:22 \
	  -device \
	  virtio-blk-device,drive=hd2 \
	  -drive \
	  if=none,file=../rootfs/base.qcow2,format=qcow2,readonly=on,id=hd2 \
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

test: busybox.img script.img ../appimage/bin/get-free-port
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
	  ../busybox-kernel/busybox-zImage \
	  -initrd \
	  busybox.img \
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


tag:
	@echo ${TAG}

hash:
	@{ \
	  echo ${OBJ} | xargs sha256sum; \
	  deps=$$($(MAKE) depends); \
	  if [[ "$$deps" != "" ]]; then \
	    for d in $$deps;do \
	      echo "$d  $$($(MAKE) -C "../$$d" hash)";\
	    done; \
	  fi; \
	} | sha256sum | cut -d' ' -f1

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
