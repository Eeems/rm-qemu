SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

TAG := ghcr.io/eeems/rm-qemu-builder:latest
OBJ := $(shell ../get-objects)

all: image

image:
	../make-image \
	  $(TAG) \
	  $(shell MAKEFLAGS= make hash) \

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
