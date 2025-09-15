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

  # VNC Server Configuration - User service that starts automatically
  systemd.user.services.x11vnc = {
    enable = true;
    description = "X11VNC Server for remote access";
    after = [ "graphical-session.target" ];
    wantedBy = [ "default.target" ];
    
    serviceConfig = {
      Type = "exec";
      Restart = "always";
      RestartSec = "10";
      
      # Direct start - x11vnc will handle retries if X server isn't ready
      ExecStart = "${pkgs.x11vnc}/bin/x11vnc -display :10 -forever -shared -rfbport 5900 -passwd '#Rak7FR0th#' -noxdamage -wait 5";
      
      Environment = [
        "DISPLAY=:10"
        "HOME=/home/moawia"
      ];
    };
  };

  # Enable lingering for the user so user services start on boot
  systemd.tmpfiles.rules = [
    "f /var/lib/systemd/linger/moawia 0644 root root - -"
  ];

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