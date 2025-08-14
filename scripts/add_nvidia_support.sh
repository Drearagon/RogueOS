#!/usr/bin/env bash
set -e

if lspci | grep -qi nvidia; then
  echo "NVIDIA hardware detected, installing driver..."
  sudo apt-get update
  sudo apt-get install -y nvidia-driver
  echo "Driver installed. Reboot required."
else
  echo "No NVIDIA hardware found."
fi
