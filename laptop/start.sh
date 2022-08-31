#!/bin/sh

## Check if the script was executed as root
[[ "$EUID" -ne 0 ]] && echo "Please run as root" && exit 1

## Load the config file
source ./config
echo "loaded config"

## Check libvirtd
[[ $(systemctl status libvirtd | grep running) ]] || systemctl start libvirtd && sleep 1 && LIBVIRTD=STOPPED
echo "started libvirtd"

## Memory lock limit
[[ $ULIMIT != $ULIMIT_TARGET ]] && ulimit -l $ULIMIT_TARGET
echo "set memory lock limit"

## Kill the console
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind
echo "killed the console"

## Detach the GPU
virsh nodedev-detach $VIRSH_GPU --driver=vfio #> /dev/null 2>&1
virsh nodedev-detach $VIRSH_AUDIO --driver=vfio #> /dev/null 2>&1
echo "detached the gpu"

## unload existing drivers
modprobe -r $VIDEO_MODULE
modprobe -r $AUDIO_MODULE
echo "unloaded existing drivers"

## Load vfio
modprobe vfio
modprobe vfio_iommu_type1
modprobe vfio-pci
echo "loaded vfio driver"

lspci -nnk > lspci.txt

## QEMU (VM) command
./qemu.sh &
echo "finished qemu, now waiting"

## Wait for QEMU
wait
echo "finished waiting"

# reload graphics drivers
modprobe $AUDIO_MODULE
modprobe $VIDEO_MODULE
echo "reloaded amd graphics drivers"

## Unload vfio
modprobe -r vfio-pci
modprobe -r vfio_iommu_type1
modprobe -r vfio
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
