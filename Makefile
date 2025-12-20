KERNEL := 5.8.18

MAKEFLAGS += --no-print-directory
MAKE_TARGET := $(MAKE) KERNEL=${KERNEL} -C
SHELL := /bin/bash
TARGETS := $(shell find . -mindepth 2 -maxdepth 2 -type f -name Makefile | xargs dirname | xargs -n1 basename)

.PHONY: all $(TARGETS)
all: $(TARGETS)

define make-target
$1: $2
	${MAKE_TARGET} $1
endef
$(foreach T,\
	$(TARGETS),\
	$(eval $(call make-target, \
		$(T), \
		$(shell MAKEFLAGS= $(MAKE_TARGET) $(T) depends), \
	)) \
)

define make-target
.PHONY: $2
$2: $1
	${MAKE_TARGET} $1 test
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	test-$(T), \
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
	$(shell $(MAKE_TARGET) $(T) tag), \
)))

define make-target
.PHONY: $2
$2:
	podman pull "$3"
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	pull-$(T), \
	$(shell $(MAKE_TARGET) $(T) tag), \
)))

define make-target
.PHONY: $2
$2:
	@$(MAKE_TARGET) $1 tag
endef
$(foreach T, $(TARGETS), $(eval $(call make-target, \
	$(T), \
	tag-$(T), \
)))

.PHONY: tags
tags: $(foreach T, $(TARGETS),tag-$(T))

.PHONY: push
push: $(foreach T, $(TARGETS),push-$(T))

.PHONY: pull
pull: $(foreach T, $(TARGETS),pull-$(T))

.PHONY: clean
clean:
	rm -rf .data .cache

.PHONY: run-ui
run-ui: ${TARGETS}
	$(MAKE_TARGET) emulator run-ui

.PHONY: run-cli
run-cli: ${TARGETS}
	$(MAKE_TARGET) emulator run-cli

.PHONY: run-test
test: $(foreach T, $(TARGETS),test-$(T))
