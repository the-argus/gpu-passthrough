#!/bin/sh

source ./config

qemu-img create -f raw disk_image $SIZE

if [[ ! -e $VIRTIO_PATH ]]; then
    wget "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso" -O "$VIRTIO_PATH"
fi
