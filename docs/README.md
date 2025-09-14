# NixOS Remote Access Configuration

This repository contains a secure, organized NixOS configuration for a 24/7 remote access server with RDP and VNC support.

## Structure

`
nixos-config/
├── flake.nix                 # Main flake configuration
├── modules/                  # Modular NixOS configurations
│   ├── base-system.nix      # Basic system configuration
│   ├── hardware-configuration.nix # Hardware-specific settings
│   ├── networking.nix       # Network and firewall configuration
│   ├── power-management.nix # 24/7 operation settings
│   ├── secrets.nix          # Sops secrets configuration
│   ├── services.nix         # RDP/VNC service configuration
│   └── users.nix            # User management
├── secrets/                 # Encrypted secrets (sops)
│   ├── secrets.yaml        # Encrypted configuration values
│   └── age-key.txt         # Age encryption key (private)
├── docs/                   # Documentation
│   └── README.md          # This file
└── scripts/               # Utility scripts
    └── deploy.sh         # Deployment script
`

## Features

- **Remote Access**: RDP (3389) and VNC (5900) servers
- **24/7 Operation**: Comprehensive power management preventing sleep
- **Secure Configuration**: All secrets managed with sops-nix
- **Modular Structure**: Clean, organized, and maintainable
- **SMB Integration**: Network home directory support

## Security Features

- All passwords, IPs, and sensitive data encrypted with sops
- No hardcoded secrets in configuration files
- Firewall properly configured
- Secure VNC with SSL support

## Deployment

`ash
# Initialize flake
nix flake update

# Test the configuration
sudo nixos-rebuild test --flake .#nixos

# Deploy permanently
sudo nixos-rebuild switch --flake .#nixos
`

## Remote Access

- **RDP**: Connect to port 3389 using any RDP client
- **VNC**: Connect to port 5900 using VNC client with SSL support
- **SSH**: Port 1982 for administrative access

