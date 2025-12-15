KERNEL := 5.8.18

MAKEFLAGS += --no-print-directory
SHELL := /bin/bash

MAKE_TARGET := $(MAKE) KERNEL=${KERNEL} -C
TARGETS := $(shell find . -mindepth 2 -maxdepth 2 -type f -name Makefile | xargs dirname | xargs -n1 basename)
TAGS := $(shell for t in ${TARGETS}; do ${MAKE_TARGET} "$$t" tag; done)
DEP_TARGETS := $(foreach t,$(TARGETS),.depends-$(t))

all: $(TARGETS)

.depends-%:
	@${MAKE_TARGET} $* depends

${TARGETS}: %: .depends-%
	${MAKE_TARGET} $@

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

test: ${TARGETS}
	$(MAKE_TARGET) emulator test

.PHONY: \
	all \
	$(TARGETS) \
	$(DEP_TARGETS) \
	push \
	pull \
	clean \
	tags \
	run-ui \
	run-cli \
	test
