TAG := ghcr.io/eeems/rm-qemu-artifact:busybox
OUTPUTS := busybox

include ../target.mk

test:: busybox
	./artifact/busybox --help
