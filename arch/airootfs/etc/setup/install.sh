#! /bin/bash

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

# cp -r /boot /mnt/boot

# bootstrap arch install
pacman-key --init
pacman-key --populate archlinux
reflector --latest 15 --sort rate --save /etc/pacman.d/mirrorlist
pacman -Sy
pacstrap /mnt $(cat ./packages)
genfstab -U /mnt > /mnt/etc/fstab

# copy user info
cp /etc/{group,gshadow,passwd,shadow,sudoers} /mnt/etc
cp -r /home/zero /mnt/home || :

# copy options with overrides, if any
cp -r /etc/options /mnt/etc
cp /etc/options/override/* /mnt/etc/options

# working in the installed system
cp ./chroot_setup.sh /mnt/chroot_setup.sh
chmod +x /mnt/chroot_setup.sh
arch-chroot /mnt /chroot_setup.sh

[ -n "$(cat /etc/options/REBOOT)" ] && reboot
