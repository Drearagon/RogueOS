#!/usr/bin/env bash
# Install the live system to a selected disk
set -e

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root" >&2
  exit 1
fi

echo "WARNING: This will erase the target disk." >&2
lsblk
read -rp "Enter target disk (e.g. /dev/sda): " TARGET

if [ ! -b "$TARGET" ]; then
  echo "Invalid target" >&2
  exit 1
fi

read -rp "Proceed with installation to $TARGET? [y/N] " confirm
[ "$confirm" = "y" ] || exit 1

# Partition disk: GPT with EFI and root
sgdisk --zap-all "$TARGET"
sgdisk -n1:1M:+512M -t1:EF00 -c1:"EFI System" "$TARGET"
sgdisk -n2:0:0 -t2:8300 -c2:"RogueOS" "$TARGET"

EFI_PART="${TARGET}1"
ROOT_PART="${TARGET}2"
mkfs.vfat -F32 "$EFI_PART"
mkfs.ext4 -F "$ROOT_PART"

# Mount and copy filesystem
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot
rsync -aHAX --exclude='/proc/*' --exclude='/sys/*' --exclude='/dev/*' / /mnt

# Install GRUB
chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=RogueOS --recheck
chroot /mnt grub-install --target=i386-pc "$TARGET"
chroot /mnt update-grub

# Write fstab
echo "UUID=$(blkid -s UUID -o value $ROOT_PART) / ext4 defaults 0 1" > /mnt/etc/fstab
echo "UUID=$(blkid -s UUID -o value $EFI_PART) /boot vfat defaults 0 2" >> /mnt/etc/fstab

# Create new user
read -rp "Enter password for rogue user: " -s PASS && echo
chroot /mnt useradd -m -s /usr/bin/zsh -G sudo,docker rogue
chroot /mnt bash -c "echo 'rogue:$PASS' | chpasswd"

# Disable autologin
rm -f /mnt/etc/lightdm/lightdm.conf

# Enable services
chroot /mnt systemctl enable NetworkManager
chroot /mnt systemctl enable ufw
chroot /mnt systemctl enable fail2ban

# Run post-install hardening
chroot /mnt /usr/local/sbin/post_install_hardening.sh

echo "Installation complete. Reboot into your new system."
