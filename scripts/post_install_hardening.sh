#!/usr/bin/env bash
# Apply security hardening after installation
set -e

# Disable passwordless sudo for rogue
if [ -f /etc/sudoers.d/rogue ]; then
  sed -i 's/NOPASSWD: //g' /etc/sudoers.d/rogue
fi

# Apply sysctl
sysctl -p /etc/sysctl.d/99-rogueos.conf

# Enable firewall
ufw default deny incoming
ufw default allow outgoing
ufw --force enable

# Enable fail2ban
systemctl enable --now fail2ban

# Optional SSH server
if [ -d /home/rogue/.ssh ] && [ -n "$(ls -A /home/rogue/.ssh 2>/dev/null)" ]; then
  apt-get update && apt-get install -y openssh-server
  systemctl enable --now ssh
  sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
  sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
  systemctl restart ssh
fi
