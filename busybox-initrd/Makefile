TAG := ghcr.io/eeems/rm-qemu-artifact:busybox-initrd
OUTPUTS := busybox.img
TEST_DEPENDS += busybox-kernel qemu-system-arm

include ../target.mk

script.img: script
	qemu-img create script.img 1M
	mkfs.vfat script.img
	mcopy -i script.img script ::init

run: busybox.img script.img ../appimage/bin/get-free-port
	$(MAKE) -C ../busybox-kernel busybox-zImage
	$(MAKE) -C ../rootfs base.qcow2
	$(MAKE) -C ../qemu-system-arm qemu-system-arm
	port=$$(../appimage/bin/get-free-port); \
	cpus=$$(nproc); \
	echo "RM_BUSYBOX_PORT=$${port}"; \
	echo "cpus=$${cpus}"; \
	PATH="$$(pwd)/qemu-system-arm/artifact:$$PATH" qemu-system-arm \
	  -machine \
	  virt \
	  -smp \
	  cpus=$${cpus} \
	  -m \
	  size=2048 \
	  -kernel \
	  ../busybox-kernel/artifact/busybox-zImage \
	  -initrd \
	  artifact/busybox.img \
	  -append \
	  "quiet" \
	  -device \
	  virtio-net-device,netdev=net0 \
	  -netdev \
	  user,id=net0,hostfwd=tcp::$$port-:22 \
	  -device \
	  virtio-blk-device,drive=hd2 \
	  -drive \
	  if=none,file=../rootfs/artifact/base.qcow2,format=qcow2,readonly=on,id=hd2 \
	  -device \
	  virtio-blk-device,drive=hd1 \
	  -drive \
	  if=none,file=null-co://,format=raw,id=hd1 \
	  -device \
	  virtio-blk-device,drive=hd0 \
	  -drive \
	  if=none,file=null-co://,format=raw,id=hd0 \
	  -serial \
	  mon:stdio \
	  -nographic

test:: busybox.img script.img ../appimage/bin/get-free-port
	port=$$(../appimage/bin/get-free-port); \
	cpus=$$(nproc); \
	echo "RM_BUSYBOX_PORT=$${port}"; \
	echo "cpus=$${cpus}"; \
	PATH="$$(pwd)/qemu-system-arm/artifact:$$PATH" qemu-system-arm \
	  -machine \
	  virt \
	  -smp \
	  cpus=$${cpus} \
	  -m \
	  size=2048 \
	  -kernel \
	  ../busybox-kernel/artifact/busybox-zImage \
	  -initrd \
	  artifact/busybox.img \
	   -device \
	  virtio-net-device,netdev=net0 \
	  -netdev \
	  user,id=net0,hostfwd=tcp::$$port-:22 \
	  -device \
	  virtio-blk-device,drive=hd0 \
	  -drive \
	  if=none,file=script.img,format=raw,id=hd0 \
	  -serial \
	  mon:stdio \
	  -nographic
