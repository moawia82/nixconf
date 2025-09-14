#!/usr/bin/env bash
# SECURE version - generates new keys instead of using committed ones

set -euo pipefail

print_status() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

print_status "🔐 Secure NixOS Setup - Generating Fresh Keys"

# Generate NEW age key for this system
print_status "Generating fresh Age encryption key..."
age-keygen -o age-key.txt

# Extract public key  
AGE_PUBLIC_KEY=$(grep "# public key:" age-key.txt | sed 's/# public key: //')

# Create new .sops.yaml with the fresh key
tee .sops.yaml > /dev/null << EOL
keys:
  - &age_key $AGE_PUBLIC_KEY

creation_rules:
  - path_regex: \.ya?ml$
    key_groups:
    - age:
      - *age_key
EOL

print_status "Created fresh SOPS configuration"

# Prompt for credentials (never stored in repo)
echo "Enter SMB credentials for this deployment:"
read -p "SMB Username: " SMB_USERNAME
read -s -p "SMB Password: " SMB_PASSWORD
echo

read -p "SSH Port (default 1982): " SSH_PORT
SSH_PORT=${SSH_PORT:-1982}

# Create fresh secrets file
tee secrets-plain.yaml > /dev/null << EOL
# Fresh secrets for this system
ssh_port: "$SSH_PORT"
smb:
  server: "10.1.0.9"
  share: "nixos"
  username: "$SMB_USERNAME"  
  password: "$SMB_PASSWORD"
  mount_point: "/home/moawia/smb-mount"
EOL

# Encrypt secrets
SOPS_AGE_KEY_FILE=age-key.txt sops --encrypt secrets-plain.yaml > secrets.yaml
rm secrets-plain.yaml

print_status "✅ Fresh encrypted secrets created"
print_status "🔑 This system now has unique keys - fully secure"

# Continue with normal setup...
