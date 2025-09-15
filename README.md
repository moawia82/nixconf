# 🐧 NixOS Configuration - Windows User Friendly

**Secure, Remote-Ready NixOS Configuration for Windows Users**

This repository provides a complete, production-ready NixOS configuration designed specifically for users transitioning from Windows environments.

## 🎯 Features

- **🖥️ Windows Remote Desktop (RDP)** - Native Windows connectivity
- **🔍 Cross-Platform VNC** - Universal remote desktop access  
- **🔒 Secure SSH** - Remote terminal on custom port (not 22)
- **🛡️ Security First** - All secrets encrypted, minimal attack surface
- **💤 Always Available** - Power management prevents sleep
- **🏠 Network Integration** - SMB home directory support

## 📁 Repository Structure

```
nixos-config/
├── 📖 docs/                    # Beginner-friendly documentation
│   ├── README.md              # Getting started guide
│   └── TROUBLESHOOTING.md     # Common issues & solutions
├── 🔧 scripts/                # Setup automation  
│   └── setup.sh               # One-command installation
├── ⚙️ nixos/                   # NixOS configuration
│   ├── flake.nix              # Main configuration entry point
│   ├── modules/               # Modular configuration components
│   └── secrets/               # Encrypted secrets (SOPS)
└── 📋 README.md               # This file
```

## 🚀 Quick Start

1. **Clone this repository** on your NixOS system
2. **Run setup**: `sudo ./scripts/setup.sh`  
3. **Connect remotely** using RDP, VNC, or SSH

## 🔧 Connection Details

After setup, connect to your NixOS machine:

| Service | Port | Purpose | Client |
|---------|------|---------|---------|
| **RDP** | 3389 | Windows Remote Desktop | Windows built-in RDP |
| **VNC** | 5900 | Cross-platform remote desktop | Any VNC client |
| **SSH** | 1982 | Secure terminal access | PuTTY, Windows Terminal |

> **Security Note**: Default SSH port 22 is disabled for security

## 📖 Documentation

- **New to NixOS?** → Start with [`docs/README.md`](docs/README.md)
- **Having issues?** → Check [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md)

## 🛡️ Security Features

- ✅ **No hardcoded secrets** - All sensitive data encrypted with SOPS
- ✅ **Custom SSH port** - Default port 22 disabled  
- ✅ **Minimal firewall** - Only necessary ports open
- ✅ **Secure by default** - Production-ready security settings

## 🔄 Stage 2: Automated ISO Generation

**Coming Soon**: Automated NixOS ISO generation with:
- Zero-touch deployment via iPXE
- Encrypted secrets management  
- Network-based configuration deployment
- Complete automation from bare metal to running system

---

## 🏗️ For Developers

This configuration uses:
- **NixOS Flakes** for reproducible builds
- **SOPS-nix** for secrets management  
- **Modular structure** for maintainability
- **Security-first approach** for production use

---

*This configuration is optimized for Windows users transitioning to NixOS*

**Repository**: https://github.com/moawia82/nixconf
