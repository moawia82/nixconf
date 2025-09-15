# Secure NixOS Configuration with Complete SOPS Integration
# All sensitive data is encrypted and loaded at runtime
# Safe to commit to public repositories

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # SOPS secrets configuration
  sops.defaultSopsFile = ./secrets.yaml;
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";  # Generic system location
  
  # Define SOPS secrets (paths reference encrypted values)
  sops.secrets = {
    "ssh/port" = { owner = "root"; };
    "ssh/authorized_key" = { owner = "root"; };
    "firewall/allowed_tcp_ports" = { owner = "root"; };
    "smb/server_ip" = { owner = "root"; };
    "smb/share_name" = { owner = "root"; };
    "smb/username" = { owner = "root"; };
    "smb/password" = { owner = "root"; mode = "0400"; };
    "smb/mount_point" = { owner = "root"; };
    "network/hostname" = { owner = "root"; };
    "users/main_user" = { owner = "root"; };
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Network configuration using secrets
  networking.networkmanager.enable = true;
  
  # Time zone
  time.timeZone = "America/New_York";

  # Locale settings
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Desktop environment
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.layout = "us";

  # Audio
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Printing
  services.printing.enable = true;

  # User configuration (will be populated by setup script)
  users.users.placeholder-user = {
    isNormalUser = true;
    description = "User account configured by setup script";
    extraGroups = [ "networkmanager" "wheel" "ssh-users" "tty" "video" "docker" ];
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

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget  
    git
    sops
    age
    cifs-utils
    docker
    docker-compose
    yq-go
  ];

  # Programs
  programs.firefox.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Services (configured by setup script with secrets)
  services.openssh = {
    enable = true;
    settings = {
      AllowGroups = [ "ssh-users" ];
      PasswordAuthentication = false;
    };
  };

  # RDP and VNC
  services.xrdp = {
    enable = true;
    defaultWindowManager = "gnome-session";
    openFirewall = false;
  };
  
  services.x11vnc = {
    enable = true; 
    display = 0;
  };

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Firewall (will be configured by setup script)
  networking.firewall.enable = true;

  # Placeholder for SMB mount (will be configured by setup script)
  # fileSystems will be added dynamically

  system.stateVersion = "23.11";
}
