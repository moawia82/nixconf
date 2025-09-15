# User Management Configuration
{ config, pkgs, ... }:

{
  # Define users
  users.users.moawia = {
    isNormalUser = true;
    description = "Main User";
    home = "/home/moawia";
    createHome = false; # Using SMB mount
    extraGroups = [ 
      "networkmanager" 
      "wheel" 
      "ssh-users" 
      "tty" 
      "video" 
      "docker" 
    ];
    packages = with pkgs; [
      firefox
      thunderbird
      vscode
      git
      curl
      wget
      htop
      tree
      unzip
      zip
    ];
  };

  # Enable programs
  programs.firefox.enable = true;
  
  # Docker configuration
  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
}