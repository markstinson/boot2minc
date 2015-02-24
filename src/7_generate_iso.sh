#!/bin/sh

rm -f boot2minc_live.iso

cd work/kernel
cd $(ls -d *)

make isoimage FDINITRD=../../rootfs.cpio.gz
cp arch/x86/boot/image.iso ../../../boot2minc_live.iso

cd ../../..

