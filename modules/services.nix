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
    defaultWindowManager = " gnome-session\;
 openFirewall = false; # We handle firewall manually for security
 };

 # VNC Server Configuration using x11vnc
 systemd.services.x11vnc = {
 enable = true;
 description = \X11VNC Server for remote access\;
 after = [ \display-manager.service\ ];
 wantedBy = [ \multi-user.target\ ];
 
 serviceConfig = {
 Type = \simple\;
 User = \moawia\;
 Group = \users\;
 Restart = \always\;
 RestartSec = \5\;
 
 ExecStart = \\/bin/bash -c while ! \${pkgs.xorg.xdpyinfo}/bin/xdpyinfo -display :0 >/dev/null 2>&1; do sleep 2; done; exec \${pkgs.x11vnc}/bin/x11vnc -display :0 -forever -shared -rfbport 5900 -passwdfile /run/secrets/vnc_password -ssl -noxdamage \;
 
 Environment = [
 \DISPLAY=:0\
 \HOME=/home/moawia\
 ];
 };
 };

 # Install required packages for VNC
 environment.systemPackages = with pkgs; [
 x11vnc
 openssl
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
