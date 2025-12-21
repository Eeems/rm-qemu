KERNEL ?= 5.8.18
TAG := ghcr.io/eeems/rm-qemu-artifact:busybox-kernel-${KERNEL}
OUTPUTS := busybox-zImage
BUILD_ARGS := "KERNEL=$(KERNEL)"

include ../target.mk
