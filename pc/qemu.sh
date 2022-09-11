#!/bin/bash

# useful for understanding usb passthrough options (by port, product, etc)
# https://unix.stackexchange.com/questions/452934/can-i-pass-through-a-usb-port-via-qemu-command-line

source ./config

if [[ $1 == "debug" ]]; then
    echo "debugging..."
    qemu-system-x86_64 -runas $VM_USER \
        -enable-kvm \
        -m $RAM \
        -smp $CORES \
        -cpu host,kvm=on,hv_relaxed,hv_spinlocks=0x1fff,hv_time,hv_vapic,hv_vendor_id=0xDEADBEEFFF \
        -device virtio-net-pci,netdev=n1 \
        -netdev user,id=n1 \
        -rtc clock=host,base=localtime \
        -bios $OVMF \
        -drive file=$WINDOWS_IMG,media=disk,format=raw >> $LOG 2>&1
else
    qemu-system-x86_64 -runas $VM_USER \
        -enable-kvm \
        -m $RAM \
        -rtc clock=host,base=localtime \
        -smp $CORES \
        -nographic \
        -cpu host,kvm=on,hv_relaxed,hv_spinlocks=0x1fff,hv_time,hv_vapic,hv_vendor_id=0xDEADBEEFFF \
        -bios $OVMF \
        -device vfio-pci,host=$IOMMU_GPU,x-vga=on,romfile=$ROMFILE \
        -device vfio-pci,host=$IOMMU_GPU_AUDIO \
        -usb \
        -device usb-host,hostbus=1,hostport=5 \
        -device usb-host,hostbus=1,hostport=6 \
        -drive file=$WINDOWS_IMG,media=disk,format=raw >> $LOG 2>&1
        # -device virtio-net-pci,netdev=n1 \
        # -netdev user,id=n1 \
fi

