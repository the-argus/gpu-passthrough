#!/bin/bash

source config

qemu-img create -f raw disk_image $SIZE
