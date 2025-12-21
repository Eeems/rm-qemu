SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

OBJ := $(shell ../tools/get-objects)
ifndef TAG
$(error TAG must be defined)
endif

.PHONY: all
all: image

.PHONY: image
image::
	../tools/make-image \
	  $(TAG) \
	  $$(MAKEFLAGS= make hash) \
	  $(foreach A, $(BUILD_ARGS), --build-arg=$(A))

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
	  ${OBJ} \
	  $(shell MAKEFLAGS= ../tools/get-depends-static-flags) \
	  $(foreach A, $(HASH_ARGS), --static=$(A))

.SILENT: depends
.PHONY: depends
depends:
	echo $(DEPENDS)

.SILENT: config
.PHONY: config
config:
ifndef CONFIGS
	echo "DEFAULT=1"
else
	$(foreach C,$(CONFIGS),echo $(C);)
endif
