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

tag:
	@echo ${TAG}

hash:
	@@../tools/get-hash \
	  --single \
	  --static=kernel=${KERNEL} \
	  ${OBJ} \
	  $($$($(MAKE) KERNEL=${KERNEL} depends) | xargs -rI {} echo "--static{}=$$($(MAKE) KERNEL=${KERNEL} -C "../{}" hash)")

depends:
	@echo kernel busybox.img busybox rm2fb qemu-system-arm

test:
	@true

.PHONY: \
	all \
	tag \
	hash \
	depends \
	image \
	test
