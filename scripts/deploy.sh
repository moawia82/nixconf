#!/usr/bin/env bash
# NixOS Deployment Script

set -e

echo " === NixOS Configuration Deployment ===\

# Check if we're in the right directory
if [ ! -f \flake.nix\ ]; then
 echo \Error: flake.nix not found. Run this script from the nixos-config directory.\
 exit 1
fi

# Update flake inputs
echo \Updating flake inputs...\
nix flake update

# Test the configuration first
echo \Testing configuration...\
sudo nixos-rebuild test --flake .#nixos

# If test succeeds, apply permanently
echo \Configuration test successful. Applying permanently...\
sudo nixos-rebuild switch --flake .#nixos

echo \=== Deployment Complete ===\
echo \Services should now be running:\
echo \- SSH: Port 1982\
echo \- RDP: Port 3389\ 
echo \- VNC: Port 5900\
echo \\
echo \Check service status with:\
echo " systemctl status xrdp\
echo " systemctl status x11vnc\
