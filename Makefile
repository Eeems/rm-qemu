all: emulator

kernel: $(shell find kernel -type f)
	podman build -t localhost/rm-qemu:kernel kernel

rootfs: kernel $(shell find rootfs -type f)
	podman build -t localhost/rm-qemu:rootfs rootfs

emulator: rootfs $(shell find emulator -type f)
	podman build -t localhost/rm-qemu:emulator emulator

.data/rootfs.qcow2: $(shell find rootfs -type f)
	mkdir -p .data .cache
	podman run --rm -it -v .data:/data -v .cache:/cache localhost/rm-qemu:rootfs initialize-image

run: emulator .data/rootfs.qcow2
	mkdir -p .data .cache
	podman run --rm -it \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  localhost/rm-qemu:emulator

run-display: emulator .data/rootfs.qcow2
	mkdir -p .data .cache
	xhost +local:$(shell hostnamectl hostname); \
	podman run --rm -it \
	  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
	  --env DISPLAY \
	  --hostname="$(shell hostnamectl hostname)" \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  localhost/rm-qemu:emulator \
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
