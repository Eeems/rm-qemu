VERSION ?= 3.22.0.64
APPDIR := "rm-qemu.AppDir"
DEPENDS := emulator

TAG := ghcr.io/eeems/rm-qemu-appimage-builder:latest

include ../target.mk

all:: image rm-qemu-anylinux-x86_64.AppImage

rm-qemu-anylinux-x86_64.AppImage: $(OBJ)
	podman run --rm \
	  --volume=$$(pwd):/workspace \
	  --workdir=/workspace \
	  "--env=APPDIR=${APPDIR}" \
	  "${TAG}"

test:: rm-qemu-anylinux-x86_64.AppImage
	./rm-qemu-anylinux-x86_64.AppImage \
	  ${VERSION} \
	  true
