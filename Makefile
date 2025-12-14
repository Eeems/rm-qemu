all: emulator

KERNEL := 5.8.18

kernel: kernel_${KERNEL}

rootfs: rootfs_${KERNEL}

emulator: emulator_${KERNEL}

kernel_${KERNEL}: $(shell find kernel -type f)
	podman build \
	  --tag="ghcr.io/eeems/rm-qemu-kernel:${KERNEL}" \
	  --build-arg=VERSION=${KERNEL} \
	  kernel

rootfs_${KERNEL}: kernel_${KERNEL} $(shell find rootfs -type f)
	podman build \
	  --tag="ghcr.io/eeems/rm-qemu-rootfs:kernel-${KERNEL}" \
	  --build-arg=KERNEL=${KERNEL} \
	  rootfs

emulator_${KERNEL}: rootfs_${KERNEL} $(shell find emulator -type f)
	podman build \
	  --tag="ghcr.io/eeems/rm-qemu:kernel-${KERNEL}" \
	  emulator

.data/rootfs.qcow2: $(shell find rootfs -type f)
	mkdir -p .data .cache
	podman run --rm -it \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  "ghcr.io/eeems/rm-qemu-rootfs:kernel-${KERNEL}" \
	  initialize-image

run: emulator_${KERNEL} .data/rootfs.qcow2
	mkdir -p .data .cache
	podman run --rm -it \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  "ghcr.io/eeems/rm-qemu:kernel-${KERNEL}"

run-display: emulator_${KERNEL} .data/rootfs.qcow2
	mkdir -p .data .cache
	xhost +local:$(shell hostnamectl hostname); \
	podman run --rm -it \
	  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
	  --env DISPLAY \
	  --hostname="$(shell hostnamectl hostname)" \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ghcr.io/eeems/rm-qemu:emulator \
	  --display

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
