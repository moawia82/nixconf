# Network Configuration  
{ config, ... }:

{
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    
    firewall = {
      enable = true;
      # Use default ports for now, will be managed by secrets later
      allowedTCPPorts = [ 1982 3389 5900 ]; # SSH, RDP, VNC
      allowPing = true;
    };
  };

  # SSH Configuration
  services.openssh = {
    enable = true;
    settings = {
      AllowGroups = [ "ssh-users" ];
      Port = 1982;
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # SMB/CIFS mount configuration - using secrets from sops
  fileSystems."/home/moawia" = {
    device = "//\${config.sops.secrets.smb_server_ip.path}/\${config.sops.secrets.smb_share_name.path}";
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