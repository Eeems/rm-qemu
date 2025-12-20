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
	    --build-arg=KERNEL=${KERNEL} \
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
