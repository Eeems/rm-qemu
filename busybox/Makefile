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

test: busybox
	./artifact/busybox --help


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
