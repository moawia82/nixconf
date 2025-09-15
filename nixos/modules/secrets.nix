# SOPS Secrets Configuration - SECURE
{ config, ... }:

{
  # SOPS Configuration for managing secrets securely
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age = {
      # Age key will be created during setup
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    # Define secrets that will be available to the system
    secrets = {
      # SMB credentials
      smb_server_ip = {
        owner = "root";
        group = "root";
        mode = "0400";
      };
      smb_password = {
        owner = "root";
        group = "root";
        mode = "0400";
      };
      smb_username = {
        owner = "root";
        group = "root";
        mode = "0400";
      };
      
      # Service passwords
      vnc_password = {
        owner = "moawia";
        group = "users";
        mode = "0400";
      };
      user_password = {
        owner = "root";
        group = "root";
        mode = "0400";
      };
      
      # Network configuration
      ssh_port = {
        owner = "root";
        group = "root";
        mode = "0444";
      };
      rdp_port = {
        owner = "root";
        group = "root";
        mode = "0444";
      };
      vnc_port = {
        owner = "root";
        group = "root";
        mode = "0444";
      };
    };
  };
}
