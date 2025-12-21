SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

OBJ := $(shell ../tools/get-objects)
ifndef KERNEL
$(error KERNEL must be defined)
endif
ifndef TAG
$(error TAG must be defined)
endif

.PHONY: all
all: image

.PHONY: image
image:
	../tools/make-image \
	  $(TAG) \
	  $$(MAKE_FLAGS= make hash) \
	  $(foreach A, $(BUILD_ARGS), --build-arg=$(A)) \
	  "--build-arg=KERNEL=$(KERNEL)"

define make-target
.PHONY: $1
$1: $2
$2: image
	../tools/get-artifact "${TAG}" $1
endef
$(foreach O,\
	$(OUTPUTS),\
	$(eval $(call make-target, \
		$(O), \
		artifact/$(O) \
	)) \
)

.PHONY: test
test:

.SILENT: tag
.PHONY: tag
tag:
	echo ${TAG}

.SILENT: hash
.PHONY: hash
hash:
	../tools/get-hash \
	  --single \
	  $(foreach A, $(HASH_ARGS), --static=$(A)) \
	  ${OBJ} \
	  $(KERNEL="$(KERNEL)" ../tools/get-depends-static-flags)

.SILENT: depends
.PHONY: depends
depends:
	echo $(DEPENDS)
