TAG := ghcr.io/eeems/rm-qemu-artifact:busybox
OUTPUTS := busybox

ifndef KERNEL
KERNEL := 5.8.18
endif

include ../target.mk

test: busybox
	./artifact/busybox --help
