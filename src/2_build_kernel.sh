#!/bin/sh

cd work/kernel

# Change to the first directory ls finds, e.g. 'linux-3.18.6'
cd $(ls -d *)

# Cleans up the kernel sources, including configuration files
make mrproper

# Create a default configuration file for the kernel
make defconfig

# Changes the name of the system
sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\"boot2minc\"/" .config

# Config for MINC support
sed -i "s/.*CONFIG_OVERLAY_FS\ .*/CONFIG_OVERLAY_FS=y/" .config
sed -i "s/.*CONFIG_SQUASHFS\ .*/CONFIG_SQUASHFS=y/" .config

make olddefconfig

# Compile the kernel
# Good explanation of the different kernels
# http://unix.stackexchange.com/questions/5518/what-is-the-difference-between-the-following-kernel-makefile-terms-vmlinux-vmlinux
make bzImage -j `nproc`

cd ../../..

