# Power Management Configuration - 24/7 Server Operation
{ config, pkgs, ... }:

{
  # =======================================================================
  # CRITICAL: Power Management - Prevent sleep for 24/7 server operation  
  # =======================================================================
  services.logind.extraConfig = ''
    HandleSuspendKey=ignore
    HandleLidSwitch=ignore
    HandleLidSwitchExternalPower=ignore
    HandleLidSwitchDocked=ignore
    IdleAction=ignore
    IdleActionSec=infinity
    HandlePowerKey=poweroff
    PowerKeyIgnoreInhibited=no
  '';

  # Disable systemd sleep targets completely
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # Additional power management settings
  powerManagement = {
    enable = true;
    # Do not suspend when lid is closed
    powertop.enable = false;
    # Prevent automatic suspension
    cpuFreqGovernor = "performance";
  };

  # Prevent ACPI sleep events
  boot.kernelParams = [ 
    "acpi_sleep=off" 
    "apm=off"
  ];

  # Services to ensure 24/7 operation
  systemd.services.prevent-sleep = {
    enable = true;
    description = "Prevent system sleep - 24/7 server operation";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "/bin/sh -c 'while true; do echo prevent-sleep > /dev/null; sleep 300; done'";
      Restart = "always";
      RestartSec = "10";
    };
  };
}