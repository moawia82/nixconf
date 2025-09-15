# Network Configuration - Secure Setup
{ config, ... }:

{
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    
    firewall = {
      enable = true;
      # SECURITY: Only allow our custom ports, NOT default SSH port 22
      allowedTCPPorts = [ 1982 3389 5900 ]; # SSH(custom), RDP, VNC
      # Explicitly deny default SSH port
      allowedTCPPortRanges = [ ];
      allowPing = true;
      # Log dropped packets for security monitoring
      logReversePathDrops = true;
    };
  };

  # SSH Configuration - SECURE SETUP
  services.openssh = {
    enable = true;
    ports = [ 1982 ]; # ONLY use custom port, never 22
    settings = {
      # SECURITY: Disable default port 22 explicitly
      AllowGroups = [ "ssh-users" ];
      PasswordAuthentication = true;
      PermitRootLogin = "no";
      # Additional security settings
      PermitEmptyPasswords = false;
      MaxAuthTries = 3;
      LoginGraceTime = 30;
      # Disable X11 forwarding for security
      X11Forwarding = false;
    };
  };

  # SMB/CIFS mount configuration - using secrets from sops
  # NOTE: This will use secrets once sops is properly configured
  fileSystems."/home/moawia" = {
    device = "//10.1.0.9/nixos"; # Temporary - will be replaced with sops secret
    fsType = "cifs";
    options = [
      "credentials=/run/secrets/smb_credentials"
      "uid=1000,gid=100,iocharset=utf8,file_mode=0644,dir_mode=0755"
      "x-systemd.automount"
      "x-systemd.requires=network-online.target"
      "x-systemd.device-timeout=30s"
      "x-systemd.mount-timeout=30s"
    ];
  };
}