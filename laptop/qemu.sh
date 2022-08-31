#!/bin/sh

# useful for understanding usb passthrough options (by port, product, etc)
# https://unix.stackexchange.com/questions/452934/can-i-pass-through-a-usb-port-via-qemu-command-line

source ./config

if [[ $1 == "debug" ]]; then
    echo "debugging..."
    qemu-system-x86_64 -runas $VM_USER \
        -enable-kvm \
        -m $RAM \
        -rtc clock=host,base=localtime \
        -smp $CORES,sockets=1,cores=$(( $CORES / 2 )),threads=2 \
        -parallel none -serial none \
        -cpu host,kvm=off,hv_relaxed,hv_spinlocks=0x1fff,hv_time,hv_vapic,hv_vendor_id=0xDEADBEEFFF \
        -bios /etc/ovmf/OVMF_CODE.fd \
        -device virtio-net-pci,netdev=n1 \
        -netdev user,id=n1 \
        -usb \
        -device usb-host,hostbus=1,hostport=5 \
        -device usb-host,hostbus=1,hostport=6 \
        -drive file=$WINDOWS_IMG,media=disk,format=raw >> $LOG 2>&1
else
    qemu-system-x86_64 -runas $VM_USER \
        -enable-kvm \
        -m $RAM \
        -rtc clock=host,base=localtime \
        -smp $CORES,sockets=1,cores=$(( $CORES / 2 )),threads=2 \
        -nographic -vga none -parallel none -serial none \
        -cpu host,kvm=off,hv_relaxed,hv_spinlocks=0x1fff,hv_time,hv_vapic,hv_vendor_id=0xDEADBEEFFF \
        -bios /etc/ovmf/OVMF_CODE.fd \
        -device virtio-net-pci,netdev=n1 \
        -netdev user,id=n1 \
        -device vfio-pci,host=$IOMMU_GPU,multifunction=on,x-vga=on \
        -usb \
        -device usb-host,hostbus=1,hostport=5 \
        -device usb-host,hostbus=1,hostport=6 \
        -drive file=$WINDOWS_IMG,media=disk,format=raw >> $LOG 2>&1
        # -device vfio-pci,host=$IOMMU_GPU_AUDIO \
        # -device vfio-pci,host=$IOMMU_AUDIO_SECONDARY \
        # -device vfio-pci,host="00:1f.4" \
        # -device vfio-pci,host="00:1f.5" \
fi

