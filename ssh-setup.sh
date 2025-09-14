#!/usr/bin/env bash
# SSH Keys and User Setup Script

set -euo pipefail

print_status() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

# Check if user moawia exists, create if not
if ! id "moawia" &>/dev/null; then
    print_status "Creating user moawia..."
    sudo useradd -m -s /bin/zsh -G wheel,users,ssh-users,docker moawia
    echo "moawia:moawia123" | sudo chpasswd  # Default password, change as needed
fi

# Create SSH directory
sudo mkdir -p /home/moawia/.ssh
sudo chmod 700 /home/moawia/.ssh

# Generate SSH key pair if not exists
if [ ! -f /home/moawia/.ssh/id_ed25519 ]; then
    print_status "Generating SSH key pair..."
    sudo -u moawia ssh-keygen -t ed25519 -f /home/moawia/.ssh/id_ed25519 -N ""
    sudo -u moawia cp /home/moawia/.ssh/id_ed25519.pub /home/moawia/.ssh/authorized_keys
fi

# Set proper permissions
sudo chown -R moawia:users /home/moawia/.ssh
sudo chmod 600 /home/moawia/.ssh/*
sudo chmod 644 /home/moawia/.ssh/*.pub /home/moawia/.ssh/authorized_keys

print_status "SSH setup completed for user moawia"
print_status "Public key location: /home/moawia/.ssh/id_ed25519.pub"
