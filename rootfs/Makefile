TAG := ghcr.io/eeems/rm-qemu-artifact:rootfs
OUTPUTS := base.qcow2

all:: .shrink-image .WAIT image $(OUTPUTS)

include ../target.mk

.shrink-image: ../emulator/bin/shrink-image
	cp ../emulator/bin/shrink-image .shrink-image
