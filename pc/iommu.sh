#!/bin/bash
## Outputs the IOMMU groups and the devices inside them
## Source [https://wiki.installgentoo.com/index.php/PCI_passthrough#Step_2:_Find_out_your_IOMMU_groups]
for iommu_group in \
  $(find /sys/kernel/iommu_groups/ -maxdepth 1 -mindepth 1 -type d); do \
  echo "IOMMU group $(basename "$iommu_group")"; \
  for device in $(ls -1 "$iommu_group"/devices/); do \
    echo -n $'\t'; lspci -nns "$device"; \
  done; \
done
