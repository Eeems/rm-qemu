VERSION := 3.22.0.64
APPDIR="rm-qemu.AppDir"

SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

ifndef KERNEL
$(error KERNEL is not set)
endif

TAG := ghcr.io/eeems/rm-qemu-appimage-builder:kernel-${KERNEL}
OBJ := $(shell ../tools/get-objects)
OTHEROBJ := $(shell { git ls-files --other --exclude-standard ../{rootfs,emulator}/bin;git ls-files --no-others --exclude-standard ../{rootfs,emulator}/bin; } | uniq | sort)

all: image rm-qemu-kernel-${KERNEL}-anylinux-x86_64.AppImage

image: $(OBJ)
	../tools/make-image \
	  ${TAG} \
	  $$($(MAKE) hash) \
	  "--build-arg=KERNEL=${KERNEL}"

rm-qemu-kernel-${KERNEL}-anylinux-x86_64.AppImage: $(OBJ)
	podman run --rm \
	  --volume=$$(pwd):/workspace \
	  --workdir=/workspace \
	  "--env=KERNEL=${KERNEL}" \
	  "--env=APPDIR=${APPDIR}" \
	  "${TAG}"

tag:
	@echo ${TAG}

hash:
	@../tools/get-hash \
	  --single \
	  --static=kernel=${KERNEL} \
	  ${OBJ} \
	  $($$($(MAKE) KERNEL=${KERNEL} depends) | xargs -rI {} echo "--static{}=$$($(MAKE) KERNEL=${KERNEL} -C "../{}" hash)")

depends:
	@echo emulator

test: rm-qemu-kernel-${KERNEL}-anylinux-x86_64.AppImage
	./rm-qemu-kernel-${KERNEL}-anylinux-x86_64.AppImage \
	  ${VERSION} \
	  true

.PHONY: \
	all \
	tag \
	hash \
	depends \
	test \
	image
