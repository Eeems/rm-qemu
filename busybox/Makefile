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
	$(MAKE) -C ../kernel KERNEL=${KERNEL} zImage qemu.dtb
	port=$$(../appimage/bin/get-free-port); \
	echo "RM_BUSYBOX_PORT=$$port0"; \
	qemu-system-arm \
	  -machine mcimx7d-sabre \
	  -cpu cortex-a9 \
	  -smp 2 \
	  -m 2048 \
	  -kernel ../kernel/zImage \
	  -dtb ../kernel/qemu.dtb \
	  -initrd busybox.img \
	  -append "console=ttymxc0 quiet init=/init" \
	  -nic \
	  "user,hostfwd=tcp::$${port}-:22" \
	  -serial \
	  mon:stdio \
	  -nographic

test: busybox.img script.img ../appimage/bin/get-free-port
	$(MAKE) -C ../kernel KERNEL=${KERNEL} zImage qemu.dtb
	port=$$(../appimage/bin/get-free-port); \
	echo "RM_BUSYBOX_PORT=$$port0"; \
	qemu-system-arm \
	  -machine mcimx7d-sabre \
	  -cpu cortex-a9 \
	  -smp 2 \
	  -m 2048 \
	  -kernel ../kernel/zImage \
	  -dtb ../kernel/qemu.dtb \
	  -initrd busybox.img \
	  -append "console=ttymxc0 init=/init" \
	  -drive \
	  if=sd,file=script.img,format=raw,index=0 \
	  -nic \
	  "user,hostfwd=tcp::$${port}-:22" \
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
	@true

.PHONY: \
	all \
	tag \
	hash \
	depends \
	image \
	run \
	test
