SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

TAG := ghcr.io/eeems/rm-qemu-builder:latest
OBJ := $(shell { git ls-files --other --exclude-standard;git ls-files --no-others --exclude-standard; } | uniq | sort)

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
	    --tag=$$tag \
	    "--build-arg=HASH=$$local" \
	    .; \
	else \
	  echo "Skipped as hash matches"; \
	fi

tag:
	@echo ${TAG}

hash:
	@{ \
	  echo $$(skopeo inspect docker://ghcr.io/eeems/arkes-builder:master --format='{{ .Digest }}' | cut -d':' -f2); \
	  echo ${OBJ} | xargs sha256sum; \
	} | sha256sum | cut -d' ' -f1

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
