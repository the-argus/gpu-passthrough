#!/bin/sh

# reload graphics drivers
modprobe snd_hda_intel
modprobe drm
modprobe i2c_algo_bit
modprobe drm_kms_helper
modprobe ttm
modprobe gpu_sched
modprobe amdgpu
echo "reloaded amd graphics drivers"

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

## Reload the framebuffer and console
echo 1 > /sys/class/vtconsole/vtcon0/bind
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind
echo "reloaded framebuffer and console"

## If libvirtd was stopped then stop it
[[ $LIBVIRTD == "STOPPED" ]] && systemctl stop libvirtd
echo "stopped libvirtd"

## Restore ulimit
ulimit -l $ULIMIT
