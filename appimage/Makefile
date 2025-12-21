VERSION := 3.22.0.64
APPDIR="rm-qemu.AppDir"

TAG := ghcr.io/eeems/rm-qemu-appimage-builder:kernel-${KERNEL}

include ../target.mk

all: image rm-qemu-kernel-${KERNEL}-anylinux-x86_64.AppImage

rm-qemu-kernel-${KERNEL}-anylinux-x86_64.AppImage: $(OBJ)
	podman run --rm \
	  --volume=$$(pwd):/workspace \
	  --workdir=/workspace \
	  "--env=KERNEL=${KERNEL}" \
	  "--env=APPDIR=${APPDIR}" \
	  "${TAG}"

test: rm-qemu-kernel-${KERNEL}-anylinux-x86_64.AppImage
	./rm-qemu-kernel-${KERNEL}-anylinux-x86_64.AppImage \
	  ${VERSION} \
	  true
