#!/bin/bash

source config

qemu-system-x86_64 -runas $VM_USER \
    -enable-kvm \
    -vga none -parallel none -serial none \
    -m $RAM \
    -rtc clock=host,base=localtime \
    -smp $CORES \
    -cpu host,kvm=on,hv_relaxed,hv_spinlocks=0x1fff,hv_time,hv_vapic,hv_vendor_id=0xDEADBEEFFF \
    -device vfio-pci,host=$IOMMU_GPU,x-vga=on,romfile=$ROMFILE \
    -device vfio-pci,host=$IOMMU_GPU_AUDIO \
    -device virtio-net-pci,netdev=n1 \
    -netdev user,id=n1 \
    -drive file=$WINDOWS_IMG,media=disk,format=raw >> $LOG 2>&1
