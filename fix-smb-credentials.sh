#!/usr/bin/env bash
# SMB Credentials Fix Script

set -euo pipefail

NIXOS_CONFIG="/etc/nixos"

print_status() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1"
}

echo "🔧 SMB Credentials Fix Tool"
echo "This script helps you update SMB credentials and test the connection"
echo ""

# Check if SOPS is available
if ! command -v sops &> /dev/null; then
    print_error "SOPS not found. Please run the main setup script first."
    exit 1
fi

# Function to update credentials in SOPS
update_sops_credentials() {
    print_status "Current SMB configuration:"
    sudo SOPS_AGE_KEY_FILE="$NIXOS_CONFIG/secrets/age-key.txt" sops -d "$NIXOS_CONFIG/secrets.yaml" | grep -A 5 "smb:"
    
    echo ""
    read -p "Do you want to update the SMB credentials? (y/N): " update_creds
    
    if [[ $update_creds =~ ^[Yy]$ ]]; then
        print_status "Opening SOPS editor..."
        print_status "Navigate to smb: -> password: and update the password"
        sudo SOPS_AGE_KEY_FILE="$NIXOS_CONFIG/secrets/age-key.txt" sops "$NIXOS_CONFIG/secrets.yaml"
        
        # Recreate credentials file
        print_status "Updating SMB credentials file..."
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
        
        print_status "SMB credentials updated successfully!"
    fi
}

# Function to test SMB connection
test_smb_connection() {
    print_status "Testing SMB connection..."
    
    # Check server connectivity
    if ping -c 1 10.1.0.9 &>/dev/null; then
        print_status "✅ Server 10.1.0.9 is reachable"
    else
        print_error "❌ Server 10.1.0.9 is not reachable"
        return 1
    fi
    
    # Check SMB port
    if nc -zv 10.1.0.9 445 2>/dev/null; then
        print_status "✅ SMB port 445 is open"
    else
        print_error "❌ SMB port 445 is not accessible"
        return 1
    fi
    
    # Test mount
    print_status "Testing SMB mount..."
    sudo mkdir -p /tmp/smb-test
    
    if sudo mount.cifs //10.1.0.9/nixos /tmp/smb-test -o credentials="$NIXOS_CONFIG/smb-credentials",uid=1000,gid=100 2>/dev/null; then
        print_status "✅ SMB mount successful!"
        sudo ls -la /tmp/smb-test/ 2>/dev/null || true
        sudo umount /tmp/smb-test
        print_status "✅ SMB mount test completed successfully"
    else
        print_error "❌ SMB mount failed"
        print_error "Check the following on your SMB server:"
        print_error "1. User exists and has correct password"
        print_error "2. Share 'nixos' exists and is accessible"
        print_error "3. SMB/CIFS service is running"
        print_error "4. Firewall allows SMB traffic"
        return 1
    fi
    
    sudo rmdir /tmp/smb-test
}

# Function to restart SMB automount
restart_automount() {
    print_status "Restarting SMB automount service..."
    sudo systemctl restart 'home-moawia-smb\x2dmount.automount' 2>/dev/null || true
    print_status "Automount service restarted"
}

# Menu
while true; do
    echo ""
    echo "Choose an option:"
    echo "1) Update SMB credentials in SOPS"
    echo "2) Test SMB connection"
    echo "3) Restart automount service"
    echo "4) Show current configuration"
    echo "5) Exit"
    echo ""
    read -p "Enter your choice (1-5): " choice
    
    case $choice in
        1) update_sops_credentials ;;
        2) test_smb_connection ;;
        3) restart_automount ;;
        4) 
            print_status "Current SMB configuration:"
            sudo SOPS_AGE_KEY_FILE="$NIXOS_CONFIG/secrets/age-key.txt" sops -d "$NIXOS_CONFIG/secrets.yaml" | grep -A 5 "smb:"
            ;;
        5) 
            print_status "Goodbye!"
            exit 0
            ;;
        *) 
            print_error "Invalid choice. Please enter 1-5."
            ;;
    esac
done
