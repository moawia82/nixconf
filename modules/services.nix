# Remote Access Services Configuration
{ config, pkgs, ... }:

{
  # Enable X11 and desktop environment
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  # RDP Configuration (xrdp)
  services.xrdp = {
    enable = true;
    defaultWindowManager = "gnome-session";
    openFirewall = false; # We handle firewall manually for security
  };

  # Install VNC packages
  environment.systemPackages = with pkgs; [
    x11vnc
    tigervnc
    openssl
  ];

  # VNC Server Configuration using x11vnc as a systemd service
  systemd.services.x11vnc = {
    enable = true;
    description = "X11VNC Server for remote access";
    after = [ "display-manager.service" "graphical-session.target" ];
    wants = [ "display-manager.service" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "simple";
      User = "moawia";
      Group = "users";
      Restart = "always";
      RestartSec = "5";
      
      ExecStartPre = "${pkgs.bash}/bin/bash -c 'while ! ${pkgs.xorg.xdpyinfo}/bin/xdpyinfo -display :0 >/dev/null 2>&1; do echo Waiting for X server...; sleep 2; done'";
      
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -display :0 -forever -shared -rfbport 5900 -passwd '#Rak7FR0th#' -noxdamage -noxfixes -noxcomposite -nomodtweak -noxrecord";
      
      Environment = [
        "DISPLAY=:0"
        "HOME=/home/moawia"
      ];
    };
  };

  # Audio configuration
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}