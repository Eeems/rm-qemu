KERNEL := 5.8.18

MAKEFLAGS += --no-print-directory
MAKE_TARGET := $(MAKE) KERNEL=${KERNEL} -C
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
	for t in $$($(MAKE) tags);do \
	  podman rmi $$t; \
	done

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
	${MAKE_TARGET} $1
endef
$(foreach T,\
	$(TARGETS),\
	$(eval $(call make-target, \
		$(T), \
		$(shell MAKEFLAGS= MAKEFLAGS= $(MAKE_TARGET) $(T) depends), \
	)) \
)

define make-target
.PHONY: $2
$2: $1 $3
	${MAKE_TARGET} $1 test
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	test-$(T), \
	$(foreach D,$(shell MAKEFLAGS= KERNEL="${KERNEL}" tools/get-depends $(T)),test-$(D)), \
)))

define make-target
.PHONY: $2
$2: $1
	if podman image exists $3; then \
	  podman push $3; \
	fi
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	push-$(T), \
	$(shell MAKEFLAGS= $(MAKE_TARGET) $(T) tag), \
)))

define make-target
.PHONY: $2
$2:
	podman pull $3
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	pull-$(T), \
	$(shell MAKEFLAGS= $(MAKE_TARGET) $(T) tag), \
)))

define make-target
.SILENT: $2
.PHONY: $2
$2: $3
	@$(MAKE_TARGET) $1 tag
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	tag-$(T), \
	$(foreach D,$(shell MAKEFLAGS= KERNEL="${KERNEL}" tools/get-depends $(T)),tag-$(D)), \
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
	$(foreach D,$(shell MAKEFLAGS= KERNEL="${KERNEL}" tools/get-depends $(T)),hash-$(D)), \
)))
