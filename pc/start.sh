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

# kill pipewire
pipewire_pid=$(pgrep -u $VM_USER pipewire)
echo killing $pipewire_pid
kill $pipewire_pid
# kill xserver
x_pid=$(pgrep -u $VM_USER startx)
echo killing $x_pid
kill $x_pid

## unload existing drivers
modprobe -r amdgpu
modprobe -r gpu_sched
modprobe -r ttm
modprobe -r drm_kms_helper
modprobe -r i2c_algo_bit
modprobe -r drm
# modprobe -r snd_hda_intel
echo "unloaded existing drivers"

## Load vfio
modprobe vfio_iommu_type1
modprobe vfio
# modprobe vfio-pci
echo "loaded vfio driver"

## QEMU (VM) command
./qemu.sh &
echo "finished qemu, now waiting"

## Wait for QEMU
wait
echo "finished waiting"

./stop.sh
