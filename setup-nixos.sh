#!/usr/bin/env bash
set -euo pipefail

# NixOS Automated Setup Script
# This script clones your nixconf repo and sets up the entire system automatically

REPO_URL="https://github.com/moawia82/nixconf.git"
NIXOS_CONFIG="/etc/nixos"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Starting NixOS Automated Setup..."

# Function to print colored output
print_status() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "Don't run this script as root. It will use sudo when needed."
    exit 1
fi

# Install git if not available
if ! command -v git &> /dev/null; then
    print_status "Installing git..."
    sudo nix-env -iA nixos.git
fi

# Clone the repository
print_status "Cloning nixconf repository..."
if [ -d "nixconf" ]; then
    print_warning "nixconf directory already exists, pulling latest changes..."
    cd nixconf && git pull && cd ..
else
    git clone "$REPO_URL" nixconf
fi

# Backup current configuration
print_status "Backing up current NixOS configuration..."
sudo cp -r "$NIXOS_CONFIG" "$NIXOS_CONFIG.backup-$(date +%Y%m%d-%H%M%S)"

# Copy hardware configuration (preserve existing)
print_status "Preserving hardware configuration..."
cp "$NIXOS_CONFIG/hardware-configuration.nix" nixconf/

# Copy configuration files
print_status "Installing new configuration..."
sudo cp nixconf/configuration.nix "$NIXOS_CONFIG/"
sudo cp nixconf/.sops.yaml "$NIXOS_CONFIG/"
sudo cp nixconf/secrets.yaml "$NIXOS_CONFIG/"

# Create secrets directory and copy age key
print_status "Setting up SOPS secrets..."
sudo mkdir -p "$NIXOS_CONFIG/secrets"
sudo cp nixconf/age-key.txt "$NIXOS_CONFIG/secrets/"
sudo chmod 600 "$NIXOS_CONFIG/secrets/age-key.txt"

# Create SMB credentials from SOPS
print_status "Setting up SMB credentials..."
if command -v sops &> /dev/null && command -v age &> /dev/null; then
    # Decrypt and create credentials file
    sudo SOPS_AGE_KEY_FILE="$NIXOS_CONFIG/secrets/age-key.txt" sops -d "$NIXOS_CONFIG/secrets.yaml" | \
    sudo tee /tmp/decrypted-secrets.yaml > /dev/null
    
    SMB_PASSWORD=$(grep -A 5 "smb:" /tmp/decrypted-secrets.yaml | grep "password:" | sed 's/.*password: //' | tr -d "'\"")
    SMB_USERNAME=$(grep -A 5 "smb:" /tmp/decrypted-secrets.yaml | grep "username:" | sed 's/.*username: //' | tr -d "'\"")
    
    sudo tee "$NIXOS_CONFIG/smb-credentials" > /dev/null << EOL
username=$SMB_USERNAME
password=$SMB_PASSWORD
EOL
    sudo chmod 600 "$NIXOS_CONFIG/smb-credentials"
    sudo rm /tmp/decrypted-secrets.yaml
fi

# Create user and set up SSH keys
print_status "Setting up user and SSH keys..."
if [ -f "nixconf/ssh-setup.sh" ]; then
    bash nixconf/ssh-setup.sh
fi

# Create mount point
print_status "Creating SMB mount point..."
sudo mkdir -p /home/moawia/smb-mount
sudo chown moawia:users /home/moawia/smb-mount 2>/dev/null || true

# Rebuild NixOS
print_status "Rebuilding NixOS system..."
sudo nixos-rebuild switch

print_status "✅ NixOS setup completed successfully!"
print_status "🔑 SSH is configured on port 1982"
print_status "📁 SMB mount point: /home/moawia/smb-mount"
print_status "🔐 SOPS secrets are configured and ready"

print_warning "If SMB mount fails, verify credentials on the server side:"
print_warning "- User 'Moawia' exists on SMB server"
print_warning "- Share 'nixos' is accessible"
print_warning "- Password is correct"

echo ""
echo "🎉 System replication complete! You can now:"
echo "   - SSH to this system on port 1982"
echo "   - Access encrypted secrets with SOPS"
echo "   - Mount SMB share automatically"
