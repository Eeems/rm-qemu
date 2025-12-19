SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

TAG := ghcr.io/eeems/rm-qemu-builder:latest
OBJ := $(shell ../get-objects)

all: image

image:
	@set -e;\
	tag=${TAG}; \
	echo "Checking $$tag"; \
	local=$$($(MAKE) hash); \
	image=$$(podman inspect $$tag --format='{{ .Labels.hash }}' 2>/dev/null || skopeo inspect docker://$$tag --format='{{ .Labels.hash }}' || true); \
	if [[ "$$local" != "$$image" ]];then \
	  echo "$$local != $$image"; \
	  podman build \
	  	--format=docker \
	    --tag=$$tag \
	    "--build-arg=HASH=$$local" \
	    .; \
	else \
	  echo "Skipped as hash matches"; \
	fi

tag:
	@echo ${TAG}

hash:
	@../get-hash \
	  --single \
	  --static=ghcr.io/eeems/arkes-builder:master="$$(skopeo inspect docker://ghcr.io/eeems/arkes-builder:master --format='{{ .Digest }}' | cut -d':' -f2)" \
	  ${OBJ}

push: image
	if podman image exists ${TAG}; then \
	  podman push ${TAG}; \
	fi

.PHONY: \
	all \
	tag \
	hash \
	image \
	push
