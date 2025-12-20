SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

ifndef KERNEL
KERNEL := 5.8.18
endif

TAG := ghcr.io/eeems/rm-qemu-artifact:rm2fb
OBJ :=  $(shell ../tools/get-objects)
OUTPUTS := rm2fb.tar.gz rm2fb-emu

all: image

image:
	../tools/make-image \
	  ${TAG} \
	  $$($(MAKE) hash) \
	  "--build-arg=KERNEL=${KERNEL}"

${OUTPUTS}: image
	../tools/get-artifact "${TAG}" "$@"

tag:
	@echo ${TAG}

hash:
	@../tools/get-hash \
	  --single \
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
