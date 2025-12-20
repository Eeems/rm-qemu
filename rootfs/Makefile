SHELL := /bin/bash
MAKEFLAGS += --no-print-directory
OUTPUTS := base.qcow2

ifndef KERNEL
$(error KERNEL is not set)
endif

TAG := ghcr.io/eeems/rm-qemu-rootfs:kernel-${KERNEL}
OBJ := $(shell ../tools/get-objects)

all: image

image:
	../tools/make-image \
	  ${TAG} \
	  $$($(MAKE) hash) \
	  "--build-arg=KERNEL=${KERNEL}"

define make-target
.PHONY: $1
$1: $2
$2: image
	../tools/get-artifact "${TAG}" $1
endef
$(foreach O,\
	$(OUTPUTS),\
	$(eval $(call make-target, \
		$(O), \
		artifact/$(O) \
	)) \
)

.SILENT: tag
tag:
	@echo ${TAG}

.SILENT: hash
hash:
	@@../tools/get-hash \
	  --single \
	  --static=kernel=${KERNEL} \
	  ${OBJ} \
	  $(get-depends-static-flags)

.SILENT: depends
depends:
	@echo busybox.img busybox rm2fb qemu-system-arm .WAIT kernel

.SILENT: test
test:
	@true

.PHONY: \
	all \
	tag \
	hash \
	depends \
	image \
	test
