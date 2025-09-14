# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
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

  # Power Management - Prevent automatic sleep/suspend
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowSuspendThenHibernate=no
    AllowHybridSleep=no
  '';

  services.logind = {
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    powerKey = "ignore";
    powerKeyLongPress = "poweroff";
    extraConfig = ''
      HandlePowerKey=ignore
      HandleSuspendKey=ignore
      HandleHibernateKey=ignore
      HandleLidSwitch=ignore
      HandleLidSwitchExternalPower=ignore
      IdleAction=ignore
    '';
  };

  # X11 and Desktop Environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Printing
  services.printing.enable = true;

  # Docker
  virtualisation.docker.enable = true;

  # User account
  users.users.moawia = {
    isNormalUser = true;
    description = "Moawia Elhassan";
    extraGroups = [ "networkmanager" "wheel" "ssh-users" "tty" "video" "docker" ];
    shell = pkgs.zsh;  # zsh as default shell
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILgWTbfCpH8Dks63w9tSois6SJrSMfu5QvQm2TskBLSv moawia@nixos"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # System packages - Adding carefully
  environment.systemPackages = with pkgs; [
    # Basic tools (existing)
    vim
    zsh
    bash
    tigervnc
    xorg.xinit
    xorg.xauth
    dbus
    firefox
    git
    warp-terminal
    emacs
    
    # NEW: Additional applications
    neovim
    libreoffice
    docker
    docker-compose
    kubectl
    xpipe
    wine
    winetricks
    jetbrains.idea-community
    qownnotes
    sops
    age
    cifs-utils
  ];

  # Environment variables for proper KDE session
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "KDE";
    KDE_SESSION_VERSION = "6";
    QT_QPA_PLATFORM = "xcb";
  };

  # Warp terminal integration - for both bash and zsh
  environment.interactiveShellInit = ''
    # Auto-Warpify for bash and zsh
    if [[ "$-" == *i* ]]; then
      if [[ -n "$BASH_VERSION" ]]; then
        printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "bash", "uname": "'$(uname)'" }}\x9c'
      elif [[ -n "$ZSH_VERSION" ]]; then
        printf '\eP$f{"hook": "SourcedRcFileForWarp", "value": { "shell": "zsh", "uname": "'$(uname)'" }}\x9c'
      fi
    fi
  '';

  # Enable zsh system-wide
  programs.zsh.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  programs.firefox.enable = true;

  # SSH Server
  services.openssh = {
    enable = true;
    settings = {
      AllowGroups = [ "ssh-users" ];
      port = 1982;
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  # RDP Configuration - Simple working version
  services.xrdp = {
    enable = true;
    openFirewall = true;
    # Use simple startplasma-x11 directly
    defaultWindowManager = "startplasma-x11";
  };

  # VNC Server (for alternative remote access)
  systemd.services.vncserver1 = {
    description = "TigerVNC server on :1 for user moawia";
    after = [ "network.target" "display-manager.service" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ tigervnc xorg.xinit xorg.xauth dbus ];
    serviceConfig = {
      User = "moawia";
      Type = "simple";
      PAMName = "login";
      Environment = ["HOME=/home/moawia" "USER=moawia"];
      ExecStart = ''
        ${pkgs.tigervnc}/bin/vncserver :1 -fg \
          -localhost=no \
          -geometry 1920x1080 \
          -depth 24
      '';
      ExecStop = "${pkgs.tigervnc}/bin/vncserver -kill :1";
      Restart = "on-failure";
      RestartSec = "2s";
    };
  };

  # Firewall
  networking.firewall.allowedTCPPorts = [ 1982 5901 3389 ];

  # System version
  # SMB/CIFS Mount Configuration
  fileSystems."/home/moawia/smb-mount" = {
    device = "//10.1.0.9/nixos";
    fsType = "cifs";
    options = [
      "credentials=/etc/nixos/smb-credentials"
      "uid=1000"
      "gid=100"
      "iocharset=utf8"
      "vers=3.0"
      "nounix"
      "noauto"
      "x-systemd.automount"
      "x-systemd.idle-timeout=60"
      "x-systemd.device-timeout=5"
      "x-systemd.mount-timeout=5"
    ];
  };

  system.stateVersion = "25.05";
}
