SHELL := /bin/bash

ifndef KERNEL
$(error KERNEL is not set)
endif

TAG := ghcr.io/eeems/rm-qemu:kernel-${KERNEL}
OBJ := $(shell find . -type f -print0 | sort -z | xargs  -d"\0")

all:
	@set -e;\
	tag=${TAG}; \
	echo "Checking $$tag"; \
	local=$$(echo ${OBJ} | xargs sha256sum | sha256sum | cut -d' ' -f1); \
	image=$$(podman inspect $$tag --format='{{ .Labels.hash }}' 2>/dev/null || skopeo inspect docker://$$tag --format='{{ .Labels.hash }}'); \
	if [[ "$$local" != "$$image" ]];then \
	  echo "$$local != $$image"; \
	  podman build \
	    --tag=$$tag \
	    "--build-arg=HASH=$$local" \
	    .; \
	else \
	  echo "Skipped as hash matches"; \
	fi

.data/rootfs.qcow2: ${OBJ}
	mkdir -p .data .cache
	podman run --rm -it \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ghcr.io/eeems/rm-qemu-rootfs:kernel-${KERNEL} \
	  initialize-image

run-cli: all .data/rootfs.qcow2
	mkdir -p .data .cache
	podman run --rm -it \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ghcr.io/eeems/rm-qemu:kernel-${KERNEL}

run-ui: all .data/rootfs.qcow2
	mkdir -p .data .cache
	xhost +local:$(shell hostnamectl hostname); \
	podman run --rm -it \
	  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
	  --env DISPLAY \
	  --hostname="$(shell hostnamectl hostname)"\
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ghcr.io/eeems/rm-qemu:emulator \
	  --display

tag:
	@echo ${TAG}

depends:
	@echo rootfs

.PHONY: \
	all \
	tag \
	depends \
	run-cli \
	run-ui
