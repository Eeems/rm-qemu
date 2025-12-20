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

.SILENT: tag
tag:
	@echo ${TAG}

.SILENT: hash
hash:
	@../tools/get-hash \
	  --single \
	  ${OBJ} \
	  $(get-depends-static-flags)

.SILENT: depends
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
