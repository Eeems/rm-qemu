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
	@../tools/get-hash \
	  --single \
	  --static=kernel=${KERNEL} \
	  ${OBJ} \
	  $(get-depends-static-flags)

.SILENT: depends
depends:
	@true

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
