#!/bin/sh

source ./config

## Unload vfio
# modprobe -r vfio-pci
modprobe -r vfio
modprobe -r vfio_iommu_type1
echo "unloaded vfio driver"

## Reattach the GPU
virsh nodedev-reattach $VIRSH_AUDIO #> /dev/null 2>&1
echo "reattached audio"
virsh nodedev-reattach $VIRSH_GPU #> /dev/null 2>&1
echo "reattached gpu"

modprobe snd_hda_intel

## If libvirtd was stopped then stop it
[[ $LIBVIRTD == "STOPPED" ]] && systemctl stop libvirtd
echo "stopped libvirtd"

## Restore ulimit
# ulimit -l $ULIMIT
