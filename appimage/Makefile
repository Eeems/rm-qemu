VERSION ?= 3.22.0.64
APPDIR := "rm-qemu.AppDir"
DEPENDS := emulator
OBJ += $(shell find ../emulator/bin -type f)
TAG := ghcr.io/eeems/rm-qemu-appimage-builder:latest

include ../target.mk

all:: image rm-qemu.AppImage

rm-qemu.AppImage: .image-marker
	podman run --rm \
	  --volume=$$(pwd):/workspace \
	  --workdir=/workspace \
	  "--env=APPDIR=${APPDIR}" \
	  "--env=GITHUB_REPOSITORY=${GITHUB_REPOSITORY}" \
	  "${TAG}"

test:: rm-qemu.AppImage
	./rm-qemu.AppImage \
	  ${VERSION} \
	  true
