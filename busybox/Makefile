TAG := ghcr.io/eeems/rm-qemu-artifact:busybox
OUTPUTS := busybox mv gzip ls mkdir sh dd mktemp pidof ln

include ../target.mk

test:: busybox
	./artifact/busybox --help
