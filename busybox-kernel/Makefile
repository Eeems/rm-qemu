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
	@set -e;\
	tag=${TAG}; \
	echo "Checking $$tag"; \
	local=$$($(MAKE) KERNEL=${KERNEL} hash); \
	image=$$(podman inspect $$tag --format='{{ .Labels.hash }}' 2>/dev/null || skopeo inspect docker://$$tag --format='{{ .Labels.hash }}' || true); \
	if [[ "$$local" != "$$image" ]];then \
	  echo "$$local != $$image"; \
	  podman build \
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
