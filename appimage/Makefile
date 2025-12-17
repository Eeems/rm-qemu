VERSION := 3.22.0.64
APPDIR="rm-qemu.AppDir"

SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

ifndef KERNEL
$(error KERNEL is not set)
endif

TAG := ghcr.io/eeems/rm-qemu-appimage-builder:kernel-${KERNEL}
OBJ := $(shell { git ls-files --other --exclude-standard;git ls-files --no-others --exclude-standard; } | uniq | sort)
OTHEROBJ := $(shell { git ls-files --other --exclude-standard ../{rootfs,emulator}/bin;git ls-files --no-others --exclude-standard ../{rootfs,emulator}/bin; } | uniq | sort)

all: image rm-qemu-kernel-${KERNEL}-anylinux-x86_64.AppImage

image: $(OBJ)
	@set -e;\
	tag=${TAG}; \
	echo "Checking $$tag"; \
	local=$$($(MAKE) KERNEL=${KERNEL} hash); \
	image=$$(podman inspect $$tag --format='{{ .Labels.hash }}' 2>/dev/null || skopeo inspect docker://$$tag --format='{{ .Labels.hash }}' || true); \
	if [[ "$$local" != "$$image" ]];then \
	  echo "$$local != $$image"; \
	  podman build \
	    --tag=$$tag \
	    "--build-arg=KERNEL=${KERNEL}" \
	    "--build-arg=HASH=$$local" \
	    .; \
	else \
	  echo "Skipped as hash matches"; \
	fi

rm-qemu-kernel-${KERNEL}-anylinux-x86_64.AppImage: $(OBJ)
	podman run --rm \
	  --volume=$$(pwd):/workspace \
	  --workdir=/workspace \
	  "--env=KERNEL=${KERNEL}" \
	  "--env=APPDIR=${APPDIR}" \
	  "${TAG}"

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
	@echo emulator

test: rm-qemu-kernel-${KERNEL}-anylinux-x86_64.AppImage
	./rm-qemu-kernel-${KERNEL}-anylinux-x86_64.AppImage \
	  ${VERSION} \
	  true

.PHONY: \
	all \
	tag \
	hash \
	depends \
	test \
	image
