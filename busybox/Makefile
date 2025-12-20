SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

TAG := ghcr.io/eeems/rm-qemu-artifact:busybox
OBJ := $(shell ../tools/get-objects)
OUTPUTS := busybox

ifndef KERNEL
KERNEL := 5.8.18
endif

all: image

image:
	../tools/make-image \
	  ${TAG} \
	  $$($(MAKE) hash) \
	  "--build-arg=KERNEL=${KERNEL}"

${OUTPUTS}: image
	../tools/get-artifact "${TAG}" "$@"

test: busybox
	./busybox --help


tag:
	@echo ${TAG}

hash:
	@../tools/get-hash \
	  --single \
	  ${OBJ} \
	  $($$($(MAKE) KERNEL=${KERNEL} depends) | xargs -rI {} echo "--static{}=$$($(MAKE) KERNEL=${KERNEL} -C "../{}" hash)")

depends:
	@true

.PHONY: \
	all \
	tag \
	hash \
	depends \
	image \
	run \
	test
