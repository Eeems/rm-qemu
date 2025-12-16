SHELL := /bin/bash
MAKEFLAGS += --no-print-directory
OUTPUTS := base.qcow2

ifndef KERNEL
$(error KERNEL is not set)
endif

TAG := ghcr.io/eeems/rm-qemu-rootfs:kernel-${KERNEL}
OBJ := $(shell { git ls-files --other --exclude-standard;git ls-files --no-others --exclude-standard; } | uniq | sort)

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
	podman run --rm \
	  --volume=$$(pwd):/out \
	  --entrypoint=/bin/bash \
	  ${TAG} \
	  -c "cp /$@ /out"

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
	@echo kernel

test:
	@true

.PHONY: \
	all \
	tag \
	hash \
	depends \
	image \
	test
