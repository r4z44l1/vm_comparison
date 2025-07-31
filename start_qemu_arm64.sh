#!/bin/bash

set -e

# QEMU starten
echo "Starte QEMU ARM64 VM..."
qemu-system-aarch64 \
  -m 2048 \
  -cpu cortex-a57 \
  -M virt \
  -bios /usr/share/qemu-efi-aarch64/QEMU_EFI.fd \
  -nographic \
  -drive if=none,file=/home/raza/arm-test/debian-arm64.qcow2,id=hd,format=qcow2 \
  -device virtio-blk-device,drive=hd \
  -drive if=none,file=/home/raza/arm-test/cloud-init.img,id=cid,format=raw \
  -device virtio-blk-device,drive=cid \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 \
  -device e1000,netdev=net0


