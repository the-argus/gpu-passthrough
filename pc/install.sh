#!/bin/sh

source ./config

# checkout https://gitlab.com/YuriAlek/vfio/-/blob/master/scripts/windows-virsh.sh
# and https://gitlab.com/YuriAlek/vfio/-/wikis/Use#windows

# when loading the virtio drivers, use E:\vioscsi\w10\amd64\vioscsi.inf
    # -device virtio-net-pci,netdev=n1 \
    # -netdev user,id=n1 \
    # -rtc clock=host,base=localtime \
    # -boot order=bcd \

qemu-system-x86_64 \
    -enable-kvm \
    -m $RAM \
    -smp $CORES \
    -bios /etc/ovmf/OVMF_CODE.fd \
    -drive file=$ISO_PATH,if=none,media=cdrom,id=cd1 \
    -device ide-cd,bus=ide.1,drive=cd1 \
    -drive file=$VIRTIO_PATH,media=cdrom,if=none,id=cd2 \
    -device ide-cd,bus=ide.1,drive=cd2 \
    -device virtio-scsi-pci,id=scsi0 \
    -device scsi-hd,bus=scsi0.0,drive=rootfs \
    -drive id=rootfs,file=$WINDOWS_IMG,media=disk,format=raw,if=none
