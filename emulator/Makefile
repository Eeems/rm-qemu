VERSION := 3.22.0.64

SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

ifndef KERNEL
$(error KERNEL is not set)
endif

TAG := ghcr.io/eeems/rm-qemu:kernel-${KERNEL}
OBJ := $(shell { git ls-files --other --exclude-standard;git ls-files --no-others --exclude-standard; } | uniq | sort)

all:
	@set -e;\
	tag=${TAG}; \
	echo "Checking $$tag"; \
	local=$$($(MAKE) KERNEL=${KERNEL} hash); \
	image=$$(podman inspect $$tag --format='{{ .Labels.hash }}' 2>/dev/null || skopeo inspect docker://$$tag --format='{{ .Labels.hash }}'); \
	if [[ "$$local" != "$$image" ]];then \
	  echo "$$local != $$image"; \
	  podman build \
	    --tag=$$tag \
	    "--build-arg=HASH=$$local" \
	    .; \
	else \
	  echo "Skipped as hash matches"; \
	fi

.data/${VERSION}.qcow2: ../rootfs/bin/initialize-image
	mkdir -p .data .cache
	podman run --rm \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  --entrypoint=initialize-image \
	  ghcr.io/eeems/rm-qemu:kernel-${KERNEL} \
	  ${VERSION}

tag:
	@echo ${TAG}

hash:
	@{ \
	  echo ${KERNEL}; \
	  echo ${OBJ} | xargs sha256sum; \
	  deps=$$($(MAKE) KERNEL=${KERNEL} depends); \
	  if [[ "$$deps" != "" ]]; then \
	    for d in $$deps;do \
	      echo "$d  $$($(MAKE) KERNEL=${KERNEL} -C "../$$d" hash)";\
	    done; \
	  fi; \
	} | sha256sum | cut -d' ' -f1

depends:
	@echo rootfs

run-cli: all .data/${VERSION}.qcow2
	podman run --rm -it \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ${TAG} \
	  ${VERSION}

run-ui: all .data/${VERSION}.qcow2
	xhost +local:$(shell hostnamectl hostname); \
	podman run --rm -it \
	  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
	  --env DISPLAY \
	  --hostname="$(shell hostnamectl hostname)"\
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ${TAG} \
	  ${VERSION} \
	  --display

test: all .data/${VERSION}.qcow2
	podman run --rm \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ${TAG} \
	  ${VERSION} \
	  true

.PHONY: \
	all \
	tag \
	hash \
	depends \
	run-cli \
	run-ui \
	test
