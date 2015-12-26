#!/bin/sh

cd work

rm -rf rootfs

# Install busybox as a rootfs
cd busybox
cd $(ls -d *)

cp -R _install ../../rootfs

# Install mincs
cd ../../mincs
cd $(ls -d *)

PREFIX=../../rootfs/usr/ LIBEXEC=/usr/libexec ./install.sh

# Prepare rootfs
cd ../../rootfs

rm -f linuxrc

mkdir dev
mkdir etc
mkdir proc
mkdir root
mkdir src
mkdir sys
mkdir tmp
chmod 1777 tmp

cd etc

cat > bootscript.sh << EOF
#!/bin/sh

dmesg -n 1
mount -t devtmpfs none /dev
mount -t proc none /proc
mount -t sysfs none /sys
mount -t tmpfs tmpfs /tmp
mount -t tmpfs tmpfs /sys/fs/cgroup/

mkdir /sys/fs/cgroup/cpu
mount -t cgroup -o cpu cgroup /sys/fs/cgroup/cpu
mkdir /sys/fs/cgroup/memory
mount -t cgroup -o memory cgroup /sys/fs/cgroup/memory

EOF

chmod +x bootscript.sh

cat > welcome.txt << EOF

  #################################
  #                               #
  #  Welcome to "Boot2MINC Live"  #
  #                               #
  #################################

EOF

cat > inittab << EOF
::sysinit:/etc/bootscript.sh
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::once:cat /etc/welcome.txt
::respawn:/bin/cttyhack /bin/sh
tty2::once:cat /etc/welcome.txt
tty2::respawn:/bin/sh
tty3::once:cat /etc/welcome.txt
tty3::respawn:/bin/sh
tty4::once:cat /etc/welcome.txt
tty4::respawn:/bin/sh

EOF

cd ..

cat > init << EOF
#!/bin/sh

exec /sbin/init

EOF

chmod +x init

cp ../../*.sh src
cp ../../.config src
chmod +r src/*.sh
chmod +r src/.config

cd ../..

