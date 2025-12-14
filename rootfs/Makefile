SHELL := /bin/bash

ifndef KERNEL
$(error KERNEL is not set)
endif

TAG := ghcr.io/eeems/rm-qemu-rootfs:kernel-${KERNEL}
OBJ := $(shell find . -type f -print0 | sort -z | xargs  -d"\0")

all:
	@set -e;\
	tag=${TAG}; \
	echo "Checking $$tag"; \
	local=$$(echo ${OBJ} | xargs sha256sum | sha256sum | cut -d' ' -f1); \
	image=$$(podman inspect $$tag --format='{{ .Labels.hash }}' 2>/dev/null || skopeo inspect docker://$$tag --format='{{ .Labels.hash }}'); \
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

tag:
	@echo ${TAG}


depends:
	@echo kernel

.PHONY: \
	all \
	tag \
	depends
