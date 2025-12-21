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
clean:
	git clean --force -dX
	rm -rf $(foreach T, $(TARGETS), $(T)/artifact)
	$(foreach T, $(shell MAKEFLAGS= ${MAKE} tags),podman rmi -i $(T);)

.PHONY: run-ui
run-ui: ${TARGETS}
	$(MAKE_TARGET) emulator run-ui

.PHONY: run-cli
run-cli: ${TARGETS}
	$(MAKE_TARGET) emulator run-cli

.PHONY: run-test
test: $(foreach T, $(TARGETS),test-$(T))

define make-target
$1: $2
	$3
endef
$(foreach T,\
	$(TARGETS),\
	$(eval $(call make-target, \
		$(T), \
		$(shell MAKEFLAGS= $(MAKE_TARGET) $(T) depends), \
		$(foreach C,$(shell MAKEFLAGS= ${MAKE_TARGET} $(T) config), ${MAKE_TARGET} $(T) $(C);), \
	)) \
)

define make-target
.PHONY: $2
$2: $1 $3
	$4
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	test-$(T), \
	$(foreach D,$(shell MAKEFLAGS= tools/get-depends $(T)),test-$(D)), \
	$(foreach C,$(shell MAKEFLAGS= ${MAKE_TARGET} $(T) config), ${MAKE_TARGET} $(T) $(C) test;), \
)))

define make-target
.PHONY: $2
$2: $1
	$(foreach T, $3,if podman image exists $(T); then podman push $(T);fi;)
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	push-$(T), \
	$(foreach C,$(shell MAKEFLAGS= ${MAKE_TARGET} $(T) config),$(shell MAKEFLAGS= $(MAKE_TARGET) $(T) $(C) tag))\
)))

define make-target
.PHONY: $2
$2:
	$3
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	pull-$(T), \
	$(foreach C,$(shell MAKEFLAGS= ${MAKE_TARGET} $(T) config), podman pull $(shell MAKEFLAGS= $(MAKE_TARGET) $(T) $(C) tag);)\
)))

define make-target
.SILENT: $2
.PHONY: $2
$2: $3
	$4
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	tag-$(T), \
	$(foreach D,$(shell MAKEFLAGS= tools/get-depends $(T)),tag-$(D)), \
	$(foreach C,$(shell MAKEFLAGS= ${MAKE_TARGET} $(T) config), ${MAKE_TARGET} $(T) $(C) tag;), \
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
	$(foreach D,$(shell MAKEFLAGS= tools/get-depends $(T)),hash-$(D)), \
)))
