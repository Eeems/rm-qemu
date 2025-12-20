SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

ifndef KERNEL
$(error KERNEL is not set)
endif

TAG := ghcr.io/eeems/rm-qemu-artifact:busybox-kernel-${KERNEL}
OBJ := $(shell { git ls-files --other --exclude-standard;git ls-files --no-others --exclude-standard; } | uniq | sort)
OUTPUTS := busybox-zImage

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
