# NixOS Configuration Repository

This repository contains an automated NixOS configuration setup with SOPS-encrypted secrets and SMB mounting.

## 🚀 Quick Setup (One Command)

On a fresh NixOS installation, run:

```bash
curl -fsSL https://raw.githubusercontent.com/moawia82/nixconf/main/setup-nixos.sh | bash
```

Or manually:

```bash
git clone https://github.com/moawia82/nixconf.git
cd nixconf
chmod +x setup-nixos.sh
./setup-nixos.sh
```

## 📦 What Gets Installed

### Core Applications
- **Development**: IntelliJ IDEA Community, Neovim, Git
- **Office**: LibreOffice, QOwnNotes
- **Remote Access**: TigerVNC, XRDP
- **Browsers**: Firefox
- **Containers**: Docker, Docker Compose, kubectl
- **Security**: SOPS, Age encryption
- **Windows Compatibility**: Wine, Winetricks
- **Remote Management**: XPipe

### System Configuration
- **SSH**: Configured on port 1982
- **User**: moawia (with sudo access)
- **Shell**: Zsh with Warp terminal integration
- **SMB Mount**: Automated mounting of `//10.1.0.9/nixos`
- **SOPS**: Encrypted secrets management
- **Firewall**: Configured for SSH, VNC, RDP

## 🔐 Security Features

### SOPS Encrypted Secrets
- All sensitive data encrypted with Age
- SSH port configuration
- SMB credentials
- Secure key management

### SSH Configuration
- ED25519 key pairs auto-generated
- Port 1982 (non-standard for security)
- Key-based authentication preferred

## 🔧 Fixing SMB Credentials

If SMB mounting fails after setup, use the credential fix tool:

```bash
./fix-smb-credentials.sh
```

This tool allows you to:
1. Update SMB credentials in encrypted format
2. Test SMB server connectivity
3. Restart automount services
4. Troubleshoot connection issues

### Manual SMB Troubleshooting

Check these on your SMB server (10.1.0.9):
1. **User exists**: Verify user "Moawia" exists
2. **Share exists**: Verify share "nixos" is available
3. **Permissions**: User has read/write access to share
4. **SMB service**: Samba/SMB service is running
5. **Firewall**: Port 445 is open

## 📁 Repository Structure

```
nixconf/
├── setup-nixos.sh          # Main automated setup script
├── configuration.nix        # NixOS system configuration
├── hardware-configuration.nix  # Hardware-specific config (generated)
├── secrets.yaml            # SOPS encrypted secrets
├── .sops.yaml              # SOPS configuration
├── age-key.txt             # Age encryption key
├── ssh-setup.sh            # SSH and user setup
├── fix-smb-credentials.sh  # SMB troubleshooting tool
└── README.md               # This file
```

## 🔄 System Replication

To replicate this exact system on another machine:

1. **Fresh NixOS Installation**: Install base NixOS system
2. **Run Setup Script**: Execute the one-liner command above
3. **Verify Setup**: Check SSH, SMB mount, applications
4. **Fix Credentials**: Run credential fix tool if needed

## 🛠️ Customization

### Adding New Packages
Edit `configuration.nix` and add packages to `environment.systemPackages`

### Updating Secrets
```bash
# Edit encrypted secrets
sudo SOPS_AGE_KEY_FILE=/etc/nixos/secrets/age-key.txt sops /etc/nixos/secrets.yaml

# Rebuild system
sudo nixos-rebuild switch
```

### Changing SMB Server
1. Update server IP in `configuration.nix`
2. Update credentials in SOPS secrets
3. Rebuild system

## 📋 Post-Installation Checklist

- [ ] SSH works on port 1982
- [ ] User moawia can login
- [ ] SMB mount accessible at `/home/moawia/smb-mount`
- [ ] Docker service running
- [ ] All applications launch correctly
- [ ] SOPS secrets decrypt properly

## 🆘 Troubleshooting

### SMB Mount Issues
```bash
# Check automount status
systemctl status 'home-moawia-smb\x2dmount.automount'

# Check mount status  
systemctl status 'home-moawia-smb\x2dmount.mount'

# View recent logs
sudo journalctl -u 'home-moawia-smb\x2dmount.mount' -n 20
```

### SSH Issues
```bash
# Check SSH service
systemctl status sshd

# Test connection
ssh -p 1982 moawia@localhost
```

### SOPS Issues
```bash
# Test decryption
sudo SOPS_AGE_KEY_FILE=/etc/nixos/secrets/age-key.txt sops -d /etc/nixos/secrets.yaml
```

## 🎯 Benefits

- **Zero Configuration**: Complete system setup in one command
- **Reproducible**: Identical systems every time
- **Secure**: Encrypted secrets, secure SSH
- **Automated**: SMB mounting, user setup, SSH keys
- **Version Controlled**: All configuration in Git
- **Easy Updates**: Pull and rebuild for updates

---

💡 **Tip**: After setup, your files will be preserved across system rebuilds via the SMB mount, ensuring data persistence.
