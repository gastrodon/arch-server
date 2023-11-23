#! /bin/bash
set -x

# create a home for default user
mkdir -p /home/zero
chown zero /home/zero -R

# link systemd services
mkdir -p /etc/systemd/system-preset
cat <<EOF > /etc/systemd/system-preset/90-arch-server.preset
enable cloud-init
enable dhcpcd
enable docker
enable sshd
enable systemd-networkd
enable systemd-resolved
EOF


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
hostname $(cat /etc/options/HOSTNAME)

# generage hosts
rm -rf /etc/hosts
cat <<EOF >> /etc/hosts
127.0.0.1 localhost
::1       localhost
127.0.0.1 $(hostname)
EOF
cat /etc/options/HOSTS >> /etc/hosts

# install GRUB
mkdir -p /boot/efi
mount /dev/sda1 /boot/efi

grub-install \
    --target=x86_64-efi \
    --bootloader-id=GRUB \
    --efi-directory=/boot/efi

grub-mkconfig -o /boot/grub/grub.cfg