#!/bin/bash

echo "🔧 Updating SMB username to 'Moawia' (capitalized)..."

# Create a temporary plain secrets file with the updated username
cat > secrets-plain-temp.yaml << 'SECRETS_EOF'
ssh:
  port: 1982

smb:
  server: "10.1.0.9"
  share: "nixos"
  username: "Moawia"
  password: "Rak7FRoth"
  mount_point: "/home/moawia/smb-mount"
SECRETS_EOF

echo "✅ Created temporary secrets with capitalized username 'Moawia'"

# If age key exists, we can re-encrypt
if [ -f "age-key.txt" ]; then
    echo "🔐 Re-encrypting secrets with updated username..."
    
    # Install sops and age if not available
    if ! command -v sops &> /dev/null || ! command -v age &> /dev/null; then
        echo "Installing SOPS and age..."
        if command -v nix-env &> /dev/null; then
            nix-env -iA nixpkgs.sops nixpkgs.age
        else
            echo "⚠️  Please install SOPS and age first, then run this script again"
            exit 1
        fi
    fi
    
    # Re-encrypt the secrets
    sops -e secrets-plain-temp.yaml > secrets.yaml
    rm secrets-plain-temp.yaml
    echo "✅ Secrets updated and re-encrypted with capitalized username"
else
    echo "⚠️  Age key not found. Please run secure-setup.sh first to generate encryption keys."
fi

echo ""
echo "🔍 Updated SMB configuration:"
echo "- Username: Moawia (capitalized)"
echo "- Server: 10.1.0.9"
echo "- Share: nixos"
echo "- Mount point: /home/moawia/smb-mount"
