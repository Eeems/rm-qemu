VERSION := 3.22.0.64

SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

ifndef KERNEL
$(error KERNEL is not set)
endif

TAG := ghcr.io/eeems/rm-qemu:kernel-${KERNEL}
OBJ := $(shell ../tools/get-objects)

all:
	../tools/make-image \
	  ${TAG} \
	  $$($(MAKE) hash) \
	  "--build-arg=KERNEL=${KERNEL}"

.data/${VERSION}.qcow2: ../rootfs/bin/initialize-image
	mkdir -p .data .cache
	podman run --rm \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  --entrypoint=initialize-image \
	  ghcr.io/eeems/rm-qemu:kernel-${KERNEL} \
	  ${VERSION}

tag:
	@echo ${TAG}

hash:
	@../tools/get-hash \
	  --single \
	  --static=kernel=${KERNEL} \
	  ${OBJ} \
	  $($$($(MAKE) KERNEL=${KERNEL} depends) | xargs -rI {} echo "--static{}=$$($(MAKE) KERNEL=${KERNEL} -C "../{}" hash)")

depends:
	@echo rootfs

run-cli: all .data/${VERSION}.qcow2
	podman run --rm -it \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ${TAG} \
	  ${VERSION}

run-ui: all .data/${VERSION}.qcow2
	xhost +local:$(shell hostnamectl hostname); \
	podman run --rm -it \
	  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
	  --env DISPLAY \
	  --hostname="$(shell hostnamectl hostname)"\
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ${TAG} \
	  ${VERSION} \
	  --display

test: all .data/${VERSION}.qcow2
	podman run --rm \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ${TAG} \
	  ${VERSION} \
	  true

.PHONY: \
	all \
	tag \
	hash \
	depends \
	run-cli \
	run-ui \
	test
