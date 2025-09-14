# Base System Configuration
{ config, pkgs, ... }:

{
  # Boot configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Localization
  time.timeZone = " America/New_York\;
 i18n.defaultLocale = \en_US.UTF-8\;

 # System packages
 environment.systemPackages = with pkgs; [
 vim
 wget
 git
 curl
 htop
 tree
 unzip
 zip
 sops
 age
 cifs-utils
 ];

 # Allow unfree packages
 nixpkgs.config.allowUnfree = true;

 # Enable flakes
 nix.settings.experimental-features = [ \nix-command\ \flakes\ ];

 # System version
 system.stateVersion = \23.11\;
}
