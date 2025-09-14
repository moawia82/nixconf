# 🆘 Help! I Broke My NixOS System!

**Don't panic!** NixOS is like having **System Restore** built-in. You can always go back!

## 🚨 Emergency: System Won't Boot

### Step 1: Boot into Recovery
1. When your computer starts, you'll see a boot menu
2. Look for **older NixOS versions** (like "NixOS Configuration 1, 2, 3...")
3. Select an **older one that worked**
4. Your system will boot into the working version

### Step 2: Make It Permanent
Once you're back in a working system:
```bash
sudo nixos-rebuild --rollback switch
```

**Think of this like**: Going to "System Restore" in Windows and picking a restore point.

## 🔧 Problem: "I Changed Something and Now It's Broken"

### Quick Fix - Undo Your Changes
```bash
# Go back to the last working version
sudo nixos-rebuild --rollback switch
```

### If That Doesn't Work - Complete Fresh Start
```bash
# Download the original files again
cd ~
rm -rf nixconf
git clone https://github.com/moawia82/nixconf.git
cd nixconf

# Run the easy installer
sudo ./easy-setup.sh
```

## 🌐 Problem: "I Can't Connect to Internet"

### Quick Network Fix
```bash
# Restart network manager
sudo systemctl restart NetworkManager

# Or connect manually
nmcli device wifi list
nmcli device wifi connect "YOUR_WIFI_NAME" password "YOUR_PASSWORD"
```

## 💻 Problem: "Desktop Won't Load"

### Fix Desktop Issues
```bash
# Restart display manager
sudo systemctl restart gdm

# Or reboot completely
sudo reboot
```

## 📁 Problem: "I Lost My Files"

### Your Files Are Safe!
- NixOS only changes **system settings**, not your personal files
- Your files are in `/home/moawia/`
- Check: `ls /home/moawia/`

### If Files Are Really Gone
- Check other user directories: `ls /home/`
- Look for backups: `ls /home/moawia/.backup*` or similar

## 🔄 Complete System Rebuild (Nuclear Option)

If everything is completely broken, start fresh:

### Step 1: Boot from NixOS USB/DVD
1. Insert your NixOS installation media
2. Boot from USB/DVD
3. Get to a terminal

### Step 2: Download and Apply Configuration
```bash
# Connect to internet first
sudo systemctl start NetworkManager
nmcli device wifi connect "YOUR_WIFI" password "YOUR_PASSWORD"

# Download your configuration
git clone https://github.com/moawia82/nixconf.git
cd nixconf

# Install on fresh system
sudo ./easy-setup.sh
```

## 🔍 Useful Diagnostic Commands

### Check What's Wrong
```bash
# See system status
systemctl status

# Check recent logs
journalctl -f

# See what's using disk space
df -h

# Check memory usage
free -h
```

### Check NixOS Status
```bash
# See current configuration
nixos-version

# List available configurations to rollback to
sudo nixos-rebuild list-generations

# Switch to a specific generation (replace 5 with actual number)
sudo nixos-rebuild switch --rollback-generation 5
```

## 📞 Getting Help

### NixOS Community
- **Forum**: https://discourse.nixos.org/
- **IRC/Discord**: #nixos channels
- **Reddit**: r/NixOS

### Ask for Help - Include This Info
```bash
# Copy this info when asking for help
echo "=== SYSTEM INFO ==="
nixos-version
uname -a
systemctl status
echo "=== END SYSTEM INFO ==="
```

## 💡 Prevention Tips

1. **Test changes gradually** - don't change everything at once
2. **Keep backups** - copy important files regularly  
3. **Learn rollback** - practice using `nixos-rebuild --rollback`
4. **Read error messages** - they usually tell you what's wrong

## 🎯 Remember: NixOS is Forgiving!

Unlike Windows:
- ✅ **Updates can't permanently break your system**
- ✅ **You can always roll back to a working state**
- ✅ **Your personal files are safe from system changes**
- ✅ **Reinstalling is quick and preserves your settings**

**The worst case scenario is 10 minutes to get back to working** - much better than Windows! 🚀

---

**When in doubt: `sudo nixos-rebuild --rollback switch`** 
This is your "undo" button! 🔄
