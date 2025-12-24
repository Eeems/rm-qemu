TAG := ghcr.io/eeems/rm-qemu-artifact:busybox
OUTPUTS += busybox
OUTPUTS += dd
OUTPUTS += gzip
OUTPUTS += ln
OUTPUTS += ls
OUTPUTS += lsof
OUTPUTS += mkdir
OUTPUTS += mktemp
OUTPUTS += mv
OUTPUTS += pidof
OUTPUTS += sh
OUTPUTS += killall
OUTPUTS += readlink
OUTPUTS += sha256sum

include ../target.mk

test:: busybox
	./artifact/busybox --help
