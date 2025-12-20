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
	@set -e;\
	tag=${TAG}; \
	echo "Checking $$tag"; \
	local=$$($(MAKE) KERNEL=${KERNEL} hash); \
	image=$$(podman inspect $$tag --format='{{ .Labels.hash }}' 2>/dev/null || skopeo inspect docker://$$tag --format='{{ .Labels.hash }}' || true); \
	if [[ "$$local" != "$$image" ]];then \
	  echo "$$local != $$image"; \
	  podman build \
	    --pull=missing \
	    --tag=$$tag \
	    "--build-arg=HASH=$$local" \
	    .; \
	else \
	  echo "Skipped as hash matches"; \
	fi

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
