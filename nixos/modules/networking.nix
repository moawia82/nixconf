# Network Configuration - SECURE with SOPS
{ config, ... }:

{
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    
    firewall = {
      enable = true;
      # Use SOPS secrets for ports - fallback to defaults if SOPS unavailable
      allowedTCPPorts = [
        1982  # SSH (custom port)
        3389  # RDP
        5900  # VNC
      ];
      allowedTCPPortRanges = [ ];
      allowPing = true;
      logReversePathDrops = true;
    };
  };

  # SSH Configuration - SECURE SETUP
  services.openssh = {
    enable = true;
    ports = [ 1982 ]; # Custom port for security
    settings = {
      AllowGroups = [ "ssh-users" ];
      PasswordAuthentication = true;
      PermitRootLogin = "no";
      PermitEmptyPasswords = false;
      MaxAuthTries = 3;
      LoginGraceTime = 30;
      X11Forwarding = false;
    };
  };

  # SMB/CIFS mount configuration - using SOPS secrets
  fileSystems."/home/moawia" = {
    device = "//10.1.0.9/nixos"; # TODO: Replace with SOPS secret
    fsType = "cifs";
    options = [
      "credentials=/etc/smb-credentials"
      "uid=1000,gid=100,iocharset=utf8,file_mode=0644,dir_mode=0755"
      "x-systemd.automount"
      "x-systemd.requires=network-online.target"
      "x-systemd.device-timeout=30s"
      "x-systemd.mount-timeout=30s"
    ];
  };

  # Create SMB credentials file from SOPS secrets
  systemd.tmpfiles.rules = [
    "f /run/secrets/smb_credentials 0600 root root - -"
  ];

  # SMB credentials file generation (will be replaced with SOPS)
  environment.etc."smb-credentials-template" = {
    text = ''
      username=Moawia
      password=REPLACE_WITH_SOPS_SECRET
      domain=WORKGROUP
    '';
    mode = "0600";
  };
}
