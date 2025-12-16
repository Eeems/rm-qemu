KERNEL := 5.8.18

MAKEFLAGS += --no-print-directory
SHELL := /bin/bash

MAKE_TARGET := $(MAKE) KERNEL=${KERNEL} -C
TARGETS := $(shell find . -mindepth 2 -maxdepth 2 -type f -name Makefile | xargs dirname | xargs -n1 basename)
TAGS := $(foreach T, ${TARGETS}, $(shell MAKEFLAGS=  ${MAKE_TARGET} $(T) tag))
TEST_TARGETS := $(foreach T, $(TARGETS),test-$(T))

all: $(TARGETS)

define make-target
$1: $2
	${MAKE_TARGET} $1
endef

define make-test-target
$2: $1
	${MAKE_TARGET} $1 test
endef
$(foreach T,\
	$(TARGETS),\
	$(eval $(call make-target, \
		$(T), \
		$(shell MAKEFLAGS= $(MAKE_TARGET) $(T) depends), \
	)) \
)
$(foreach T,\
	$(TARGETS),\
	$(eval $(call make-test-target, \
		$(T), \
		test-$(T), \
	)) \
)

tags:
	@echo ${TAGS} | xargs -n1 echo

push: ${TARGETS}
	for t in ${TAGS}; do \
	  if podman image exists $$t; then \
	    podman push $$t; \
	  fi; \
	done

pull:
	for t in ${TAGS}; do \
	  podman pull $$t; \
	done

clean:
	rm -rf .data .cache

run-ui: ${TARGETS}
	$(MAKE_TARGET) emulator run-ui

run-cli: ${TARGETS}
	$(MAKE_TARGET) emulator run-cli

test: ${TEST_TARGETS}

.PHONY: \
	all \
	$(TARGETS) \
	$(TEST_TARGETS) \
	push \
	pull \
	clean \
	tags \
	run-ui \
	run-cli \
	test
