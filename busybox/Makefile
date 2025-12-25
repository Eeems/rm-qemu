TAG := ghcr.io/eeems/rm-qemu-artifact:busybox
OUTPUTS += busybox
OUTPUTS += dd
OUTPUTS += gzip
OUTPUTS += killall
OUTPUTS += ln
OUTPUTS += ls
OUTPUTS += lsof
OUTPUTS += mkdir
OUTPUTS += mktemp
OUTPUTS += mv
OUTPUTS += pidof
OUTPUTS += readlink
OUTPUTS += sh
OUTPUTS += sha256sum
OUTPUTS += stat

include ../target.mk

test:: busybox
	./artifact/busybox --help
