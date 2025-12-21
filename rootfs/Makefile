TAG := ghcr.io/eeems/rm-qemu-rootfs:latest
OUTPUTS := artifact/base.qcow2
DEPENDS := busybox.img busybox rm2fb qemu-system-arm
DEPENDS += .WAIT busybox-kernel
DEPENDS += .WAIT kernel

include ../target.mk
