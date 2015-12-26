#!/bin/sh

cd work/kernel

# Change to the first directory ls finds, e.g. 'linux-3.18.6'
cd $(ls -d *)

# Cleans up the kernel sources, including configuration files
make mrproper

# Create a default configuration file for the kernel
make defconfig

yconfig() { # configs
while [ $# -ne 0 ]; do
  sed -i "s/.*CONFIG_$1\ .*/CONFIG_$1=y/" .config
  grep ^"CONFIG_$1=y" .config || echo "CONFIG_$1=y" >> .config
  shift 1
done
}

# Changes the name of the system
sed -i "s/.*CONFIG_DEFAULT_HOSTNAME.*/CONFIG_DEFAULT_HOSTNAME=\"boot2minc\"/" .config

# Config for Virtio environment
echo "CONFIG_VIRTIO=y" >> .config
echo "CONFIG_VIRTIO_PCI=y" >> .config
echo "CONFIG_VIRTIO_MMIO=y" >> .config
echo "CONFIG_VIRTIO_CONSOLE=y" >> .config
echo "CONFIG_VIRTIO_BLK=y" >> .config
echo "CONFIG_VIRTIO_NET=y" >> .config

# Config adding Realtek NIC
echo "CONFIG_8139TOO=y" >> .config
echo "CONFIG_8139CP=y" >> .config

# Config for MINC support
sed -i "s/.*CONFIG_OVERLAY_FS\ .*/CONFIG_OVERLAY_FS=y/" .config
sed -i "s/.*CONFIG_SQUASHFS\ .*/CONFIG_SQUASHFS=y/" .config

# Config for cgroups
yconfig CGROUPS EVENTFD CGROUP_DEVICE CPUSETS CGROUP_CPUACCT \
        PAGE_COUNTER MEMCG MEMCG_SWAP MEMCG_SWAP_ENABLED \
        CGROUP_PERF CGROUP_SCHED CGROUP_HUGETLB FAIR_GROUP_SCHED \
        CFS_BANDWIDTH RT_GROUP_SCHED BLK_CGROUP

make olddefconfig

# Compile the kernel
# Good explanation of the different kernels
# http://unix.stackexchange.com/questions/5518/what-is-the-difference-between-the-following-kernel-makefile-terms-vmlinux-vmlinux
make bzImage -j `nproc`

cd ../../..

