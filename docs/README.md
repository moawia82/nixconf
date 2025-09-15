# 🐧 NixOS Configuration for Windows Users

Welcome! This repository contains a complete NixOS configuration designed specifically for users transitioning from Windows to Linux.

## 🎯 What This Configuration Provides

- **🖥️ Remote Desktop (RDP)** - Access your NixOS desktop from Windows
- **🔍 VNC Server** - Cross-platform remote desktop access
- **🔒 Secure SSH** - Remote terminal access on custom port
- **💤 Power Management** - Prevents system sleep/hibernation
- **🛡️ Firewall Protection** - Only necessary ports open
- **🏠 SMB Home Integration** - Your files from Windows network share

## 📁 Repository Structure

```
├── docs/           # Documentation (you are here!)
├── scripts/        # Setup and maintenance scripts  
├── nixos/          # NixOS configuration files
│   ├── modules/    # Modular configuration components
│   └── secrets/    # Encrypted secrets (SOPS)
└── .gitignore      # Security - prevents committing secrets
```

## 🚀 Quick Start

1. **Boot NixOS** on your target machine
2. **Run setup script**: `sudo ./scripts/setup.sh`
3. **Connect remotely**:
   - **RDP**: Use Windows Remote Desktop to connect
   - **VNC**: Use any VNC client (RealVNC, TigerVNC, etc.)
   - **SSH**: Use PuTTY or Windows Terminal

## 🔧 Connection Details

After setup, connect to your NixOS machine:

- **RDP Port**: 3389 (Windows Remote Desktop compatible)
- **VNC Port**: 5900 (Cross-platform remote desktop)  
- **SSH Port**: 1982 (Secure terminal access)
- **Default Port 22**: Disabled for security

## 🆘 Need Help?

- Check `docs/TROUBLESHOOTING.md` for common issues
- All sensitive data is encrypted and secure
- Configuration is version-controlled and backed up

## 🛡️ Security Features

- **No hardcoded passwords** - All secrets encrypted with SOPS
- **Custom SSH port** - Default port 22 disabled
- **Firewall enabled** - Only necessary ports open
- **Power management** - System stays online for remote access

---
*This configuration is optimized for users coming from Windows environments*
