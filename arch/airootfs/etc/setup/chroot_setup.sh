#! /bin/bash

# create a home for default user
mkdir -p /home/zero
chown zero /home/zero


# link systemd services
systemctl enable \
    docker sshd dhcpcd \
    systemd-networkd \
    systemd-resolved

# figure out the default network device
# if it matches `enp0s[0-9]`
# If any, enable it
DEVICE="$(ip link | grep -E 'enp0s[0-9]' | cut -d; -f2 | tr -d [:space:])"
[ -n "$DEVICE" ] && systemctl enabel "dhcpcd@$DEVICE"

# set time info
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/$(cat /etc/options/REGION) /etc/localtime
hwclock --systohc

# set locales
cat /etc/options/LOCALES > /etc/locale.gen
locale-gen

# set language conf
echo "LANG=$(cat /etc/options/LANG)" > /etc/locale.conf

# set keymap conf
echo "KEYMAP=$(cat /etc/options/KEYMAP)" > /etc/vconsole.conf

# set hostname
cat /etc/options/HOSTNAME > /etc/hostname

# generage hosts
rm -rf /etc/hosts
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.0.1 $(cat /etc/options/HOSTNAME)" >> /etc/hosts
cat /etc/options/HOSTS >> /etc/hosts

# install GRUB
mkdir -p /boot/efi
mount /dev/sda1 /boot/efi

grub-install \
    --target=x86_64-efi \
    --bootloader-id=GRUB \
    --efi-directory=/boot/efi

grub-mkconfig -o /boot/grub/grub.cfg
