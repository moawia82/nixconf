# Sops Secrets Configuration
{ config, ... }:

{
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "/home/moawia/.config/sops/age/keys.txt";
    
    secrets = {
      # Network secrets
      smb_username = {};
      smb_password = {};
      smb_server_ip = {};
      smb_share_name = {};
      
      # VNC configuration  
      vnc_password = {
        owner = "moawia";
        group = "users";
        mode = "0400";
      };
      
      # Port configurations
      ssh_port = {};
      rdp_port = {};
      vnc_port = {};
      
      # Service enablement flags
      enable_xrdp = {};
      enable_vnc = {};
    };
  };
  
  # Ensure sops age key is in the right location
  system.activationScripts.sops-age-key = ''
    mkdir -p /home/moawia/.config/sops/age
    if [ -f /home/moawia/nixos-config/secrets/age-key.txt ]; then
      cp /home/moawia/nixos-config/secrets/age-key.txt /home/moawia/.config/sops/age/keys.txt
      chown moawia:users /home/moawia/.config/sops/age/keys.txt
      chmod 600 /home/moawia/.config/sops/age/keys.txt
    fi
  '';
}