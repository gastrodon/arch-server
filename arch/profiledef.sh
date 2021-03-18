#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="arch-server"
iso_label="ARCH_$(date +%Y%m)"
iso_publisher="Eva Harris <https://github.com/gastrodon>"
iso_application="Arch Server"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
file_permissions=(
  ["/etc/group"]="0:0:644"
  ["/etc/gshadow"]="0:0:600"
  ["/etc/passwd"]="0:0:644"
  ["/etc/shadow"]="0:0:400"
  ["/etc/sudoers"]="0:0:440"
)
