#! /bin/bash
set -x

# set clock to use network time
timedatectl set-ntp true
timedatectl set-timezone EST

# config disk
sed -i "s/%disksize%/$(expr $(cat /sys/block/sda/size) - 1200000)/g" sda.dump
sfdisk /dev/sda < sda.dump
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
resize2fs /dev/sda2

# copy /boot and /
mkdir -p /mnt/{root,boot}
mount /dev/sda2 /mnt

bootstrap arch install
pacman-key --init
pacman-key --populate archlinux
reflector --latest 15 --sort rate --protocol https --save /etc/pacman.d/mirrorlist
pacman -Sy
pacstrap /mnt $(cat /etc/setup/packages)
genfstab -U /mnt > /mnt/etc/fstab


# copy options with overrides, if any
cp -r /etc/options /mnt/etc
cp /etc/options/override/* /mnt/etc/options

# working in the installed system
cp /etc/setup/chroot_setup.sh /mnt/chroot_setup.sh
chmod +x /mnt/chroot_setup.sh
arch-chroot /mnt /chroot_setup.sh

# copy user info
cp /etc/{group,gshadow,passwd,shadow,sudoers} /mnt/etc
mkdir -p /mnt/home/zero
cp -r /home/zero/. /mnt/home

if [ "$(cat /etc/options/SHUTDOWN)" = "true" ]; then shutdown now; fi
if [ "$(cat /etc/options/REBOOT)" = "true" ]; then reboot; fi
