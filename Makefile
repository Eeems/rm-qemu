
KERNEL := 5.8.18


SHELL := /bin/bash

all: emulator

kernel: kernel_${KERNEL}

rootfs: rootfs_${KERNEL}

emulator: emulator_${KERNEL}

kernel_${KERNEL}: $(shell find kernel -type f)
	@tag=ghcr.io/eeems/rm-qemu-kernel:${KERNEL}; \
	echo "Checking $$tag"; \
	local=$$(find kernel/ -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -d' ' -f1); \
	image=$$(podman inspect $$tag --format='{{ .Labels.hash }}' 2>/dev/null || skopeo inspect docker://$$tag --format='{{ .Labels.hash }}'); \
	if [[ "$$image" != "$$local" ]];then \
	  podman build \
	    --tag=$$tag \
	    --build-arg=VERSION=${KERNEL} \
	    "--build-arg=HASH=$$local" \
	    kernel; \
	else \
	  echo "Skipped as hash matches"; \
	fi

rootfs_${KERNEL}: kernel_${KERNEL} $(shell find rootfs -type f)
	@tag=ghcr.io/eeems/rm-qemu-rootfs:kernel-${KERNEL}; \
	echo "Checking $$tag"; \
	local=$$(find rootfs/ -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -d' ' -f1); \
	image=$$(podman inspect $$tag --format='{{ .Labels.hash }}' 2>/dev/null || skopeo inspect docker://$$tag --format='{{ .Labels.hash }}'); \
	if [[ "$$local" != "$$image" ]];then \
	  podman build \
	    --tag=$$tag \
	    --build-arg=KERNEL=${KERNEL} \
	    "--build-arg=HASH=$$local" \
	    rootfs; \
	else \
	  echo "Skipped as hash matches"; \
	fi

emulator_${KERNEL}: rootfs_${KERNEL} $(shell find emulator -type f)
	@tag=ghcr.io/eeems/rm-qemu:kernel-${KERNEL}; \
	echo "Checking $$tag"; \
	local=$$(find emulator/ -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum | cut -d' ' -f1); \
	image=$$(podman inspect $$tag --format='{{ .Labels.hash }}' 2>/dev/null || skopeo inspect docker://$$tag --format='{{ .Labels.hash }}'); \
	if [[ "$$local" != "$$image" ]];then \
	  podman build \
	    --tag=$$tag \
	    "--build-arg=HASH=$$local" \
	    emulator; \
	else \
	  echo "Skipped as hash matches"; \
	fi

.data/rootfs.qcow2: $(shell find rootfs -type f)
	mkdir -p .data .cache
	podman run --rm -it \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ghcr.io/eeems/rm-qemu-rootfs:kernel-${KERNEL} \
	  initialize-image

run: emulator_${KERNEL} .data/rootfs.qcow2
	mkdir -p .data .cache
	podman run --rm -it \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ghcr.io/eeems/rm-qemu:kernel-${KERNEL}

run-display: emulator_${KERNEL} .data/rootfs.qcow2
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

push: kernel_${KERNEL} rootfs_${KERNEL} emulator_${KERNEL}
	podman push ghcr.io/eeems/rm-qemu-kernel:${KERNEL}
	podman push ghcr.io/eeems/rm-qemu-rootfs:kernel-${KERNEL}
	podman push ghcr.io/eeems/rm-qemu:kernel-${KERNEL}

clean:
	rm -rf .data .cache

.PHONY: \
	all \
	run \
	run-display \
	emulator \
	kernel \
	rootfs \
	clean
