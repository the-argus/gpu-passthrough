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

## Detach the GPU
virsh nodedev-detach $VIRSH_GPU --driver=vfio #> /dev/null 2>&1
# virsh nodedev-detach $VIRSH_AUDIO --driver=vfio #> /dev/null 2>&1
echo "detached the gpu"

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

LIBVIRTD=$LIBVIRTD ./stop.sh
