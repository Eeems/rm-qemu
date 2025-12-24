VERSION ?= 3.22.0.64
TAG := ghcr.io/eeems/rm-qemu:latest

DEPENDS := busybox-initrd busybox rm2fb qemu-system-arm rootfs bash
DEPENDS += .WAIT busybox-kernel
DEPENDS += .WAIT kernel

include ../target.mk

.data/${VERSION}.qcow2: $(shell find bin -name 'initialize-image*') $(shell find bin -name 'rm-busybox-*') bin/rm-chroot ../busybox-initrd/overlay/bin/rm-chroot
	mkdir -p .data .cache
	podman run --rm \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  --entrypoint=initialize-image \
	  $(TAG) \
	  ${VERSION}

.PHONY: run-cli
run-cli: all .data/${VERSION}.qcow2
	podman run --rm -it \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ${TAG} \
	  ${VERSION}

.PHONY: run-ui
run-ui: all .data/${VERSION}.qcow2
	xhost +local:$(shell hostnamectl hostname); \
	podman run --rm -it \
	  --volume=/tmp/.X11-unix:/tmp/.X11-unix \
	  --env DISPLAY \
	  --hostname="$(shell hostnamectl hostname)"\
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ${TAG} \
	  ${VERSION} \
	  --display

test::
	@set -e; \
	TEMP_DIR=$$(mktemp -d); \
	echo "Setting up serial-client tests..."; \
	socat UNIX-LISTEN:$$TEMP_DIR/test-socket,reuseaddr,fork EXEC:cat & \
	SOCAT_PID=$$!; \
	sleep 1; \
	echo "Testing interactive..."; \
	echo "hello world" | timeout 5 ./bin/serial-client $$TEMP_DIR/test-socket | grep -q "hello world"; \
	echo "Testing arguments..."; \
	./bin/serial-client $$TEMP_DIR/test-socket "arg1" "arg2" "arg3" | grep -q "arg1 arg2 arg3"; \
	echo "Testing piped input..."; \
	echo "test input" | ./bin/serial-client $$TEMP_DIR/test-socket | grep -q "test input"; \
	echo "Testing background..."; \
	./bin/serial-client $$TEMP_DIR/test-socket & \
	CLIENT_PID=$$!; \
	sleep 2; \
	echo "Cleaning up..."; \
	kill $$CLIENT_PID 2>/dev/null || true; \
	kill $$SOCAT_PID 2>/dev/null || true; \
	rm -rf $$TEMP_DIR

test:: all .data/${VERSION}.qcow2
	podman run --rm \
	  --volume=.data:/data \
	  --volume=.cache:/cache \
	  ${TAG} \
	  ${VERSION} \
	  true

clean::
	rm -rf .cache .data
