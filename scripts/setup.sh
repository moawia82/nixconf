#!/usr/bin/env bash
set -euo pipefail

echo "🐧 NixOS Configuration Setup for Windows Users"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root (use sudo)"
   exit 1
fi

# Determine the actual user (not root when using sudo)
REAL_USER="${SUDO_USER:-$(whoami)}"
REAL_HOME=$(eval echo ~$REAL_USER)

log_info "Setting up NixOS configuration for user: $REAL_USER"
log_info "Home directory: $REAL_HOME"

# Navigate to the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

log_info "Configuration directory: $CONFIG_DIR"

# Check if we have the NixOS configuration
if [[ ! -f "$CONFIG_DIR/nixos/flake.nix" ]]; then
    log_error "NixOS flake configuration not found at $CONFIG_DIR/nixos/flake.nix"
    log_error "Make sure you're running this from the correct directory"
    exit 1
fi

# Setup SOPS if needed
if [[ ! -f "$CONFIG_DIR/nixos/secrets/age-key.txt" ]]; then
    log_warn "SOPS age key not found. You'll need to set up secrets manually."
    log_warn "See docs/README.md for instructions"
fi

# Copy configuration to system location
log_info "Copying configuration to /etc/nixos..."
cp -r "$CONFIG_DIR/nixos"/* /etc/nixos/

# Set proper ownership
chown -R root:root /etc/nixos
chmod -R 644 /etc/nixos
find /etc/nixos -type d -exec chmod 755 {} \;

# Make flake.nix readable
chmod 644 /etc/nixos/flake.nix

log_info "Building and switching to new configuration..."
cd /etc/nixos && nixos-rebuild switch --flake .

log_info "Setting up user-specific services..."
# Enable lingering for the user so services start on boot
loginctl enable-linger "$REAL_USER"

# Start and enable user services as the actual user
su - "$REAL_USER" -c "
    systemctl --user daemon-reload
    systemctl --user enable x11vnc.service || true
    systemctl --user start x11vnc.service || true
"

log_info "Checking service status..."
systemctl status xrdp.service --no-pager || log_warn "RDP service may not be running"
systemctl status sshd.service --no-pager || log_warn "SSH service may not be running"
su - "$REAL_USER" -c "systemctl --user status x11vnc.service --no-pager" || log_warn "VNC service may not be running"

echo ""
echo "🎉 Setup Complete!"
echo "=================="
echo ""
echo "Your NixOS system is now configured with:"
echo "  🖥️  RDP Server:  Port 3389 (Windows Remote Desktop)"
echo "  🔍 VNC Server:  Port 5900 (Cross-platform)"
echo "  🔒 SSH Server:  Port 1982 (Secure terminal)"
echo ""
echo "📋 Next Steps:"
echo "  1. Find your IP address: ip addr show"
echo "  2. Connect from Windows using Remote Desktop"
echo "  3. Or use VNC client for cross-platform access"
echo ""
echo "📖 For help, see: $CONFIG_DIR/docs/README.md"
echo ""
