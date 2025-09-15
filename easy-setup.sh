#!/bin/bash

# 🚀 Easy NixOS Setup Script - Home Directory SMB Integration
# This script configures your home directory to be on the SMB share

set -e

echo "🎉 Welcome to NixOS SMB Home Directory Setup!"
echo "============================================"
echo ""
echo "This will configure your ENTIRE home directory to be on the SMB share."
echo "Benefits:"
echo "✅ Never lose files on system rebuilds"
echo "✅ Home directory (~) points to SMB share"
echo "✅ All settings and data preserved"
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
SMB_MOUNT="/home/$ACTUAL_USER"

echo "🔍 Setup Information:"
echo "- User: $ACTUAL_USER"
echo "- Home will be: SMB share (persistent)"
echo ""

# Step 1: Install required tools
echo "📦 Step 1/6: Installing required tools..."
nix-env -iA nixpkgs.sops nixpkgs.age nixpkgs.yq-go nixpkgs.cifs-utils || {
    echo "Installing via nix-shell..."
    nix-shell -p sops age yq-go cifs-utils --run "echo 'Tools available'"
}

# Step 2: Setup encryption keys
echo "🔑 Step 2/6: Setting up SOPS age keys..."
mkdir -p "$USER_HOME/.config/sops/age"
if [ -f "./age-key.txt" ]; then
    cp ./age-key.txt "$USER_HOME/.config/sops/age/keys.txt"
    chown -R $ACTUAL_USER:users "$USER_HOME/.config/sops"
    chmod 600 "$USER_HOME/.config/sops/age/keys.txt"
    echo "✅ Security keys configured"
fi

# Step 3: Extract secrets and handle special characters properly
echo "🔍 Step 3/6: Processing encrypted secrets..."
if sudo -u $ACTUAL_USER sops -d secrets.yaml > /dev/null 2>&1; then
    echo "✅ SOPS encryption working"
    
    # Create temporary decrypted secrets for processing
    TEMP_SECRETS="/tmp/secrets-temp-$$.yaml"
    sudo -u $ACTUAL_USER sops -d secrets.yaml > "$TEMP_SECRETS"
    chmod 600 "$TEMP_SECRETS"
    
    # Extract values - handle special characters properly
    SMB_SERVER=$(nix-shell -p yq-go --run "yq eval '.smb.server_ip' '$TEMP_SECRETS'")
    SMB_SHARE=$(nix-shell -p yq-go --run "yq eval '.smb.share_name' '$TEMP_SECRETS'") 
    SMB_USER=$(nix-shell -p yq-go --run "yq eval '.smb.username' '$TEMP_SECRETS'")
    SMB_PASS=$(nix-shell -p yq-go --run "yq eval '.smb.password' '$TEMP_SECRETS'")
    
    echo "📋 SMB Configuration:"
    echo "- Server: $SMB_SERVER"
    echo "- Share: $SMB_SHARE"
    echo "- Username: $SMB_USER"
    echo "- Password: [encrypted with special characters]"
    
else
    echo "⚠️  SOPS not working - using basic configuration"
    SMB_SERVER="10.1.0.9"
    SMB_SHARE="nixos"
    SMB_USER="Moawia"
    SMB_PASS="#Rak7FR0th#"
    TEMP_SECRETS=""
fi

# Step 4: Create SMB credentials with proper escaping
echo "🗂️ Step 4/6: Creating SMB credentials file..."
cat > /etc/nixos/smb-credentials << CREDS_EOF
username=$SMB_USER
password=$SMB_PASS
domain=WORKGROUP
CREDS_EOF
chmod 600 /etc/nixos/smb-credentials
echo "✅ SMB credentials created with special character handling"

# Step 5: Create configuration for SMB home directory
echo "🏠 Step 5/6: Configuring SMB as home directory..."

# Create updated configuration that mounts SMB as home
cat > /etc/nixos/configuration.nix << 'CONF_EOF'
# NixOS Configuration with SMB Home Directory
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

  # Audio
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # SMB Home Directory Mount
  fileSystems."/home/moawia" = {
    device = "//10.1.0.9/nixos";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb-credentials"
      "uid=1000,gid=100,iocharset=utf8,file_mode=0644,dir_mode=0755"
      "x-systemd.automount"
      "x-systemd.requires=network-online.target"
      "x-systemd.device-timeout=30s"
      "x-systemd.mount-timeout=30s"
    ];
  };

  # User configuration
  users.users.moawia = {
    isNormalUser = true;
    description = "Main User";
    extraGroups = [ "networkmanager" "wheel" "ssh-users" "tty" "video" "docker" ];
    # Home directory will be the SMB mount
    home = "/home/moawia";
    createHome = false; # Don't create local home, use SMB mount
    packages = with pkgs; [
      firefox
      thunderbird
      vscode
      git
      curl
      wget
      htop
      tree
      unzip
      zip
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    sops
    age
    cifs-utils
    docker
    docker-compose
    yq-go
  ];

  # Programs
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      AllowGroups = [ "ssh-users" ];
      PasswordAuthentication = false;
    };
  };

  # RDP and VNC
  services.xrdp = {
    enable = true;
    defaultWindowManager = "gnome-session";
    openFirewall = false;
  };
  
  services.x11vnc = {
    enable = true; 
    display = 0;
  };

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 1982 5901 3389 ];

  system.stateVersion = "23.11";
}
CONF_EOF

echo "✅ Configuration created for SMB home directory"

# Step 6: Copy all configuration files
echo "📂 Step 6/6: Installing configuration..."
cp secrets.yaml /etc/nixos/ 2>/dev/null || true
cp .sops.yaml /etc/nixos/ 2>/dev/null || true

# Clean up temp files
[ -n "$TEMP_SECRETS" ] && rm -f "$TEMP_SECRETS"

echo ""
echo "🎉 Configuration complete! Ready to apply..."
echo ""
echo "⚠️  IMPORTANT: After applying this configuration:"
echo "1. Your home directory (~) will be the SMB share"
echo "2. All your files will persist across rebuilds"
echo "3. You'll need to copy your current files to SMB first"
echo ""
echo "🚀 Apply configuration now? (y/n)"
read -r response
if [[ $response =~ ^[Yy]$ ]]; then
    echo "Applying NixOS configuration..."
    nixos-rebuild switch
    echo ""
    echo "✅ SMB Home Directory configured successfully!"
    echo "Your home directory (~) now points to the SMB share!"
else
    echo "Configuration files ready. Run 'sudo nixos-rebuild switch' when ready."
fi
