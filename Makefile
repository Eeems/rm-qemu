all: emulator

kernel: $(shell find kernel -type f)
	podman build -t localhost/rm-qemu:kernel kernel

rootfs: kernel $(shell find rootfs -type f)
	podman build -t localhost/rm-qemu:rootfs rootfs

emulator: rootfs $(shell find emulator -type f)
	podman build -t localhost/rm-qemu:emulator emulator

.data/rootfs.qcow2: $(shell find rootfs -type f)
	mkdir -p .cache .data
	podman run --rm -it -v .data:/data -v .cache:/cache localhost/rm-qemu:rootfs initialize-image 3.3.2.1666

run: emulator .data/rootfs.qcow2
	podman run --rm -it -v .data:/data -v .cache:/cache localhost/rm-qemu:emulator


.PHONY: \
	all \
	run \
	emulator \
	kernel \
	rootfs
