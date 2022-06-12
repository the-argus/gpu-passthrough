# Windows VM Setup

# specs
```
GPU : AMD ATI Radeon RX 5600
CPU : AMD Ryzen 5 3600 (12) @ 3.600GHz
```

# process

- install qemu

- get the isos:
enterprise.iso: check the helpful link
virtio.iso: 	https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso

- add ``amd_iommu=on iommu=pt`` to your kernel parameters (``/etc/default/grub`` and then regenerate grub.cfg) 

- change the config
VM_USER should be equal to your username
other values like SMP and MEM should match your system
change IOMMU groups (like VIRSH_GPU) to match the groups on your system

- run create-disk-image.sh

add the following lines to ``/etc/libvirt/qemu.conf``

```
group = "qemu"
user = "you_user_name" # replace this with your... user name
```
add the following lines to ``/etc/libvirt/libvirtd.conf``
```
# get libvirt to log stuff
log_filters="1:qemu"
log_outputs="1:file:/var/log/libvirt/libvirtd.log"
```

- run start.sh as root

helpful link: https://rentry.co/fwt
