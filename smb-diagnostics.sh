#!/usr/bin/env bash
# SMB Diagnostics and Credential Testing Script

set -euo pipefail

print_status() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

print_warning() {
    echo -e "\033[1;33m[WARNING]\033[0m $1"
}

echo "🔍 SMB Diagnostics and Credential Testing"
echo "=========================================="

# Test basic connectivity
print_status "1. Testing server connectivity..."
if ping -c 2 10.1.0.9 &>/dev/null; then
    print_status "✅ Server 10.1.0.9 is reachable"
else
    print_error "❌ Server 10.1.0.9 is not reachable"
    exit 1
fi

# Test SMB port
print_status "2. Testing SMB port 445..."
if nc -zv 10.1.0.9 445 2>&1; then
    print_status "✅ SMB port 445 is accessible"
else
    print_error "❌ SMB port 445 is not accessible"
    exit 1
fi

# Test different credential combinations
print_status "3. Testing credential combinations..."
echo ""

# Get current credentials from SOPS
CURRENT_USER=$(sudo SOPS_AGE_KEY_FILE=/etc/nixos/secrets/age-key.txt sops -d /etc/nixos/secrets.yaml | grep -A 5 "smb:" | grep "username:" | sed 's/.*username: //' | tr -d "'\"")
CURRENT_PASS=$(sudo SOPS_AGE_KEY_FILE=/etc/nixos/secrets/age-key.txt sops -d /etc/nixos/secrets.yaml | grep -A 5 "smb:" | grep "password:" | sed 's/.*password: //' | tr -d "'\"")

print_status "Current credentials from SOPS:"
echo "  Username: '$CURRENT_USER'"
echo "  Password: '$CURRENT_PASS'"
echo ""

# Function to test SMB connection
test_smb_mount() {
    local username="$1"
    local password="$2"
    local share="$3"
    
    print_status "Testing: $username / [password hidden] / $share"
    
    # Create temporary credentials file
    local temp_cred="/tmp/test_smb_creds_$$"
    cat > "$temp_cred" << EOL
username=$username
password=$password
EOL
    chmod 600 "$temp_cred"
    
    # Create test mount point
    local test_mount="/tmp/smb_test_$$"
    mkdir -p "$test_mount"
    
    # Try mounting
    if sudo mount.cifs "//10.1.0.9/$share" "$test_mount" -o "credentials=$temp_cred,uid=1000,gid=100" 2>/dev/null; then
        print_status "✅ SUCCESS! Connection works"
        sudo ls -la "$test_mount" 2>/dev/null || true
        sudo umount "$test_mount" 2>/dev/null
        rm -f "$temp_cred"
        rmdir "$test_mount" 2>/dev/null
        return 0
    else
        print_error "❌ FAILED"
        # Clean up
        rm -f "$temp_cred"
        rmdir "$test_mount" 2>/dev/null || true
        return 1
    fi
}

# Test current credentials
print_status "Testing current SOPS credentials..."
if test_smb_mount "$CURRENT_USER" "$CURRENT_PASS" "nixos"; then
    print_status "🎉 Current credentials work! The issue might be elsewhere."
    exit 0
fi

echo ""
print_warning "Current credentials failed. Let's try variations..."
echo ""

# Test different username cases
print_status "Testing username variations..."
for test_user in "moawia" "Moawia" "MOAWIA"; do
    if test_smb_mount "$test_user" "$CURRENT_PASS" "nixos"; then
        print_status "🎉 Found working username: $test_user"
        echo "You need to update SOPS with username: $test_user"
        exit 0
    fi
done

# Test different share names
print_status "Testing share name variations..."
for test_share in "nixos" "NixOS" "NIXOS" "shared" "public"; do
    if test_smb_mount "$CURRENT_USER" "$CURRENT_PASS" "$test_share"; then
        print_status "🎉 Found working share: $test_share"
        echo "You need to update SOPS and configuration.nix with share: $test_share"
        exit 0
    fi
done

echo ""
print_error "None of the automatic tests worked. Let's try manual input..."
echo ""

# Manual credential input
while true; do
    echo "Enter credentials to test (or 'quit' to exit):"
    read -p "Username: " test_username
    
    if [[ "$test_username" == "quit" ]]; then
        break
    fi
    
    read -s -p "Password: " test_password
    echo
    read -p "Share name (default: nixos): " test_share
    test_share=${test_share:-nixos}
    
    if test_smb_mount "$test_username" "$test_password" "$test_share"; then
        print_status "🎉 SUCCESS! Working credentials found:"
        echo "  Username: $test_username"
        echo "  Password: [hidden]" 
        echo "  Share: $test_share"
        echo ""
        echo "To update your SOPS secrets:"
        echo "1. sudo SOPS_AGE_KEY_FILE=/etc/nixos/secrets/age-key.txt sops /etc/nixos/secrets.yaml"
        echo "2. Update the username, password, and share as needed"
        echo "3. Run: sudo nixos-rebuild switch"
        break
    fi
    
    echo ""
    print_error "Still didn't work. Try again or check your SMB server configuration."
    echo ""
done

print_status "Diagnostics complete!"
