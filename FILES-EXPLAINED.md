# 📁 What Each File Does (For Windows Users)

**Think of these files like parts of a Windows installation disc** - each one has a specific job to make your system work.

## 🚀 Files You Actually Need to Use

### `easy-setup.sh` - The Windows Installer
- **What it does**: Does everything automatically (like running setup.exe)
- **When to use**: First time setting up your system
- **How to use**: `sudo ./easy-setup.sh`
- **Like Windows**: Double-clicking a setup program

### `SIMPLE-GUIDE.md` - The User Manual  
- **What it does**: Step-by-step instructions in plain English
- **When to use**: When you're confused or need help
- **How to use**: Open and read it
- **Like Windows**: The "Getting Started" guide

## 🔧 System Files (You Don't Need to Touch These)

### `configuration.nix` - System Settings
- **What it does**: Contains ALL your system settings
- **When to use**: When you want to change something
- **How to use**: Edit with a text editor, then rebuild
- **Like Windows**: Registry + Control Panel + Group Policy all in one file

### `secrets.yaml` - Password Vault
- **What it does**: Stores passwords and server info (encrypted)
- **When to use**: Automatically used by setup script
- **How to use**: Don't edit directly (it's encrypted)
- **Like Windows**: Credential Manager, but encrypted

### `hardware-configuration.nix` - Device Drivers
- **What it does**: Tells NixOS what hardware you have
- **When to use**: Generated automatically, rarely changed
- **How to use**: Don't touch this unless you know what you're doing
- **Like Windows**: Device Manager settings

## 📋 Helper Files (Supporting Cast)

### `.sops.yaml` - Encryption Settings
- **What it does**: Tells the system how to encrypt/decrypt secrets
- **When to use**: Automatically used
- **How to use**: Ignore this file
- **Like Windows**: BitLocker configuration

### `.gitignore` - Privacy Protection
- **What it does**: Prevents private files from being shared
- **When to use**: Automatically protects you
- **How to use**: Ignore this file
- **Like Windows**: Hidden file attributes

### `age-key.txt` - Encryption Key
- **What it does**: Your private decryption key
- **When to use**: Generated automatically
- **How to use**: Keep this file safe and private!
- **Like Windows**: Your private SSL certificate

## 🗂️ Old Files (You Can Ignore)

These files were created during development but aren't needed:
- `setup-nixos-secure.sh` - Old complex installer
- `smb-diagnostics.sh` - Troubleshooting tool
- `fix-smb-credentials.sh` - Old utility
- `update-username.sh` - Old utility

**Think of these like leftover temp files from Windows installation.**

## 💡 What You Really Need to Know

### For Daily Use:
1. **`easy-setup.sh`** - Run this once to set everything up
2. **`SIMPLE-GUIDE.md`** - Read this when you need help

### For Advanced Users Later:
1. **`configuration.nix`** - Edit this to change system settings
2. **`secrets.yaml`** - Contains encrypted passwords (don't edit directly)

## 🔄 Common Tasks

### "I want to reinstall everything"
```bash
sudo ./easy-setup.sh
```

### "I want to change a setting"
1. Edit `configuration.nix`
2. Run: `sudo nixos-rebuild switch`

### "I broke something, go back!"
```bash
sudo nixos-rebuild --rollback switch
```

### "I want to update everything"
```bash
sudo nixos-rebuild switch --upgrade
```

---

**Remember**: You only need to understand 2 files to get started:
- `easy-setup.sh` (run once)  
- `SIMPLE-GUIDE.md` (read when confused)

Everything else is like Windows system files - they work automatically! 🎯
