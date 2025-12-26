MAKEFLAGS += --no-print-directory
MAKE_TARGET := $(MAKE) -C
SHELL := /bin/bash
TARGETS := $(shell find . -mindepth 2 -maxdepth 2 -type f -name Makefile | xargs dirname | xargs -n1 basename | LC_ALL=C sort)

.PHONY: all $(TARGETS)
all: $(TARGETS)

.PHONY: tags
tags: $(foreach T, $(TARGETS), tag-$(T))

.PHONY: hash
hash: $(foreach T, $(TARGETS), hash-$(T))

.PHONY: push
push: $(foreach T, $(TARGETS), push-$(T))

.PHONY: pull
pull: $(foreach T, $(TARGETS), pull-$(T))

.PHONY: clean
clean: $(foreach T, $(TARGETS), clean-$(T))
	git clean --force -dX

.PHONY: run-ui
run-ui: ${TARGETS}
	$(MAKE_TARGET) emulator run-ui

.PHONY: run-cli
run-cli: ${TARGETS}
	$(MAKE_TARGET) emulator run-cli

.PHONY: test
test: $(foreach T, $(TARGETS),test-$(T))

.PHONY: debug
debug: $(foreach T, $(TARGETS),debug-$(T))

define make-target
.PHONY:$1
$1: $2
	while read -r c;do \
	  $(MAKE_TARGET) $1 $$$$c; \
	done < <(${MAKE_TARGET} $1 config)
endef
$(foreach T,\
	$(TARGETS),\
	$(eval $(call make-target, \
		$(T), \
		$(shell MAKEFLAGS= $(MAKE_TARGET) $(T) depends), \
	)) \
)

define make-target
.PHONY:$2
$2:$1 $3
	while read -r c;do \
	  $(MAKE_TARGET)$1 $$$$c test; \
	done < <(${MAKE_TARGET} $1 config)
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	test-$(T), \
	$(foreach D,$(shell MAKEFLAGS= tools/get-test-depends $(T)),$(D)), \
)))

define make-target
.PHONY: $2
$2: $3
	while read -r c;do \
	  $(MAKE_TARGET) $1 $$$$c image; \
	done < <(${MAKE_TARGET} $1 config)
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	image-$(T), \
	$(shell MAKEFLAGS= tools/get-depends $(T) --prefix=image-), \
)))

define make-target
.PHONY: $2
$2:
	while read -r c;do \
	  t=$$$$($(MAKE_TARGET) $1 $$$$c tag); \
	  if podman image exists $$$$t;then \
	    podman push $$$$t; \
	  fi; \
	done < <(${MAKE_TARGET} $1 config)
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	push-$(T), \
)))

define make-target
.PHONY: $2
$2:
	while read -r c;do \
	  $(MAKE_TARGET) $1 $$$$c tag | xargs -rn1 podman pull; \
	done < <(${MAKE_TARGET} $1 config)
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	pull-$(T), \
)))

define make-target
.SILENT: $2
.PHONY: $2
$2: $3
	while read -r c;do \
	  $(MAKE_TARGET) $1 $$$$c tag; \
	done < <(${MAKE_TARGET} $1 config)
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	tag-$(T), \
	$(shell MAKEFLAGS= tools/get-depends $(T) --prefix=tag-), \
)))

define make-target
.SILENT: $2
.PHONY: $2
$2: $3
	@$(MAKE_TARGET) $1 hash | xargs echo -n
	@echo "  $1"
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	hash-$(T), \
	$(shell MAKEFLAGS= tools/get-depends $(T) --prefix=hash-), \
)))

define make-target
.SILENT: $2
.PHONY: $2
$2:
	@$(MAKE_TARGET) $1 clean
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	clean-$(T), \
)))

define make-target
.SILENT: $2
.PHONY: $2
$2:
	@echo "$1 debug:"
	@echo "======"
	@$(MAKE_TARGET) $1 debug
	@echo "======"
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	debug-$(T), \
)))
