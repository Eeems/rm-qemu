SHELL := /bin/bash
MAKEFLAGS += --no-print-directory

OBJ := $(shell ../tools/get-objects)
ifndef TAG
$(error TAG must be defined)
endif

.PHONY: all
all:: image $(OUTPUTS)

.PHONY: image
image::
	../tools/make-image \
	  $(TAG) \
	  $(shell MAKEFLAGS= make hash) \
	  $(shell MAKEFLAGS= ../tools/get-depends-build-context-flags) \
	  $(foreach A, $(BUILD_ARGS), --build-arg=$(A)) \

define make-target
.PHONY: $1
$1:: $2
$2: image
	../tools/get-artifact "${TAG}" $3
endef
$(foreach O,\
	$(OUTPUTS),\
	$(eval $(call make-target, \
		$(O), \
		artifact/$(O), \
		$$(OUTPUT_ROOT)/$(O), \
	)) \
)

.PHONY: test
test::

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

.SILENT: test-depends
.PHONY: test-depends
test-depends:
ifndef TEST_DEPENDS
	echo -n
else
	for d in $(TEST_DEPENDS);do \
	  echo "$$d"; \
	done
endif

.SILENT: config
.PHONY: config
config:
ifndef CONFIGS
	echo "DEFAULT=1"
else
	for c in $(CONFIGS);do \
	  echo "$$c"; \
	done
endif

.PHONY: clean
clean::
	git clean --force -dX
	rm -rf artifact/
	podman rmi -i ${TAG}
