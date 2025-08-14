#!/usr/bin/env bash
set -e

DEVICE=${1:-/dev/sdX}
LABEL=RogueOS

echo "Creating persistence on $DEVICE"
read -rp "Use a file instead of partition? [y/N] " filemode

if [ "$filemode" = "y" ]; then
  dd if=/dev/zero of=$DEVICE bs=1M count=1024
  mkfs.ext4 -F -L $LABEL $DEVICE
else
  mkfs.ext4 -F -L $LABEL ${DEVICE}
fi

echo "Persistence configured. Add 'persistence persistence-label=$LABEL' to kernel parameters."
