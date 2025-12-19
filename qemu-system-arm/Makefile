SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

ifndef KERNEL
KERNEL := 5.8.18
endif

TAG := ghcr.io/eeems/rm-qemu-artifact:qemu-system-arm
OBJ := $(shell { git ls-files --other --exclude-standard;git ls-files --no-others --exclude-standard; } | uniq | sort)
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
	    --tag=$$tag \
	    "--build-arg=HASH=$$local" \
	    .; \
	else \
	  echo "Skipped as hash matches"; \
	fi

${OUTPUTS}: image
	rm -rf $@
	podman run --rm \
	  --volume=$$(pwd):/out \
	  --volume=/bin:/bin:ro \
	  --volume=/usr:/usr:ro \
	  --volume=/lib:/lib:ro \
	  --volume=/lib64:/lib64:ro \
	  --entrypoint=/bin/sh \
	  ${TAG} \
	  -c "cp -r /$@ /out"

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
