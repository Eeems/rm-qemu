SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

ifndef KERNEL
KERNEL := 5.8.18
endif

TAG := ghcr.io/eeems/rm-qemu-artifact:qemu-system-arm
OBJ := $(shell ../tools/get-objects)
OUTPUTS := qemu-img qemu-system-arm qemu-pr-helper qemu-storage-daemon qemu-bridge-helper firmware libslirp.so.0.4.0

all: image

image:
	../tools/make-image \
	  ${TAG} \
	  $$($(MAKE) hash)

${OUTPUTS}: image
	../tools/get-artifact "${TAG}" "$@"

tag:
	@echo ${TAG}

hash:
	@../tools/get-hash \
	  --single \
	  --static=kernel=${KERNEL} \
	  ${OBJ} \
	  $($$($(MAKE) KERNEL=${KERNEL} depends) | xargs -rI {} echo "--static{}=$$($(MAKE) KERNEL=${KERNEL} -C "../{}" hash)")

depends:
	@true

test:
	@true

.PHONY: \
	all \
	tag \
	hash \
	depends \
	image \
	test
