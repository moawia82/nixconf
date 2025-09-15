# 🔧 Troubleshooting Guide

## 🔍 Common Issues for Windows Users

### Can't Connect via Remote Desktop (RDP)

**Problem**: Windows Remote Desktop won't connect
**Solutions**:
1. Check if port 3389 is reachable: `Test-NetConnection -ComputerName YOUR_IP -Port 3389`
2. Verify RDP service is running: `systemctl status xrdp.service`
3. Check firewall: Port 3389 should be open

### VNC Connection Fails

**Problem**: VNC client can't connect
**Solutions**:
1. Test port 5900: `Test-NetConnection -ComputerName YOUR_IP -Port 5900`
2. Check VNC service: `systemctl --user status x11vnc.service`
3. Try different VNC client (RealVNC, TightVNC, UltraVNC)

### SSH Connection Refused

**Problem**: Can't SSH to the machine
**Solutions**:
1. **Wrong port**: Use port 1982, NOT 22 (security feature)
2. Test: `ssh -p 1982 username@YOUR_IP`
3. From Windows: Use PuTTY with port 1982

### System Goes to Sleep

**Problem**: Machine becomes unreachable after a while
**Solutions**:
1. Power management should prevent this automatically
2. Check service: `systemctl status prevent-sleep.service`

### Can't Access Files

**Problem**: Home directory or files not accessible
**Solutions**:
1. SMB mount might have failed
2. Check mount status: `df -h | grep home`
3. Network connectivity to SMB server

## 🚨 Emergency Recovery

If configuration is broken:
1. Boot from NixOS installer/live USB
2. Mount your system and rollback:
   ```bash
   sudo nixos-rebuild switch --rollback
   ```

## 📞 Getting More Help

### Check Service Status
```bash
# Check all critical services
systemctl status xrdp.service
systemctl --user status x11vnc.service
systemctl status sshd.service
systemctl status prevent-sleep.service
```

### View Logs
```bash
# Check system logs
journalctl -f
journalctl -u xrdp.service
journalctl --user -u x11vnc.service
```

### Network Diagnostics
From Windows PowerShell:
```powershell
# Test ports
Test-NetConnection -ComputerName YOUR_IP -Port 3389  # RDP
Test-NetConnection -ComputerName YOUR_IP -Port 5900  # VNC
Test-NetConnection -ComputerName YOUR_IP -Port 1982  # SSH
```

## 💡 Tips for Windows Users

1. **Use Windows Terminal** instead of Command Prompt for SSH
2. **Windows Subsystem for Linux (WSL)** provides familiar Linux commands
3. **Windows Remote Desktop** works perfectly with our RDP setup
4. **PowerShell** has many Linux-equivalent commands

---
*Remember: This NixOS configuration is designed to be Windows-user friendly*
