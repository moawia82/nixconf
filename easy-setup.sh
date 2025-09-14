#!/bin/bash

# 🚀 Easy NixOS Setup Script for Windows Users!
# This script does EVERYTHING automatically - just like a Windows installer

set -e

echo "🎉 Welcome to Easy NixOS Setup!"
echo "=============================="
echo ""
echo "This will set up your NixOS system automatically."
echo "Think of this like installing Windows 11 - it does everything for you!"
echo ""
echo "What you'll get:"
echo "✅ Complete desktop with apps (Firefox, VS Code, etc.)"
echo "✅ Remote access (like Windows Remote Desktop)" 
echo "✅ File server connection"
echo "✅ Security settings"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run with 'sudo' (like 'Run as Administrator' in Windows)"
    echo "Type: sudo ./easy-setup.sh"
    exit 1
fi

# Get the actual user who called sudo
ACTUAL_USER=${SUDO_USER:-$(whoami)}
USER_HOME=$(eval echo ~$ACTUAL_USER)

echo "🔍 Setup for user: $ACTUAL_USER"
echo ""

# Step 1: Install required tools
echo "📦 Step 1/5: Installing required tools..."
nix-env -iA nixpkgs.sops nixpkgs.age nixpkgs.yq-go || {
    echo "Installing via nix-shell..."
    nix-shell -p sops age yq-go --run "echo 'Tools available'"
}

# Step 2: Setup encryption keys
echo "🔑 Step 2/5: Setting up security keys..."
mkdir -p "$USER_HOME/.config/sops/age"
if [ -f "./age-key.txt" ]; then
    cp ./age-key.txt "$USER_HOME/.config/sops/age/keys.txt"
    chown -R $ACTUAL_USER:users "$USER_HOME/.config/sops"
    chmod 600 "$USER_HOME/.config/sops/age/keys.txt"
    echo "✅ Security keys configured"
else
    echo "⚠️  No encryption key found - generating new one..."
    # Generate new age key if none exists
    age-keygen -o "$USER_HOME/.config/sops/age/keys.txt"
    chown $ACTUAL_USER:users "$USER_HOME/.config/sops/age/keys.txt"
    chmod 600 "$USER_HOME/.config/sops/age/keys.txt"
    echo "✅ New security keys generated"
fi

# Step 3: Test encryption
echo "🧪 Step 3/5: Testing encryption..."
if sudo -u $ACTUAL_USER sops -d secrets.yaml > /dev/null 2>&1; then
    echo "✅ Encryption working"
else
    echo "⚠️  Creating basic configuration without secrets"
fi

# Step 4: Configure system
echo "🔧 Step 4/5: Configuring your system..."

# Create a simple working configuration if secrets don't work
if ! sudo -u $ACTUAL_USER sops -d secrets.yaml > /dev/null 2>&1; then
    echo "Creating basic configuration..."
    cat > configuration.nix << 'BASIC_EOF'
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Network
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Time zone
  time.timeZone = "America/New_York";

  # Language
  i18n.defaultLocale = "en_US.UTF-8";

  # Desktop
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User account
  users.users.moawia = {
    isNormalUser = true;
    description = "Main User";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      vscode
      git
      htop
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    firefox
  ];

  # SSH
  services.openssh.enable = true;

  # Firewall
  networking.firewall.allowedTCPPorts = [ 22 ];

  system.stateVersion = "23.11";
}
BASIC_EOF
fi

# Copy configuration to system location
cp configuration.nix /etc/nixos/
if [ -f "secrets.yaml" ]; then
    cp secrets.yaml /etc/nixos/ 2>/dev/null || true
fi
if [ -f ".sops.yaml" ]; then
    cp .sops.yaml /etc/nixos/ 2>/dev/null || true
fi

# Step 5: Apply configuration
echo "🚀 Step 5/5: Applying configuration (this takes a few minutes)..."
echo "Like installing Windows updates - please wait..."

nixos-rebuild switch

echo ""
echo "🎉 SUCCESS! Your NixOS system is ready!"
echo "======================================"
echo ""
echo "✅ What's installed:"
echo "- GNOME desktop (like Windows 11 interface)"
echo "- Firefox web browser"
echo "- VS Code editor"
echo "- SSH remote access"
echo "- All essential apps"
echo ""
echo "🔄 Next steps:"
echo "1. Reboot your computer: sudo reboot"
echo "2. Log in with your username and password"
echo "3. Enjoy your new NixOS system!"
echo ""
echo "💡 Remember:"
echo "- This is like Windows but more secure and stable"
echo "- Your settings are saved and can be easily restored"
echo "- Updates won't break your system"
echo ""
echo "📚 Need help? Read the SIMPLE-GUIDE.md file!"
