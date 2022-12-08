#!/bin/sh

source ./config

qemu-img create -f raw disk_image $SIZE
