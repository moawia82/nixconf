# Fallback configuration without SOPS - for testing only
# This file provides fallback values when SOPS secrets are not available
{ config, lib, ... }:

{
  # Create fallback VNC password file for testing
  systemd.tmpfiles.rules = [
    "d /run/secrets 0755 root root - -"
    "f /run/secrets/vnc_password 0600 moawia users - #Rak7FR0th#"
  ];

  # Create fallback SMB credentials for testing
  environment.etc."smb-credentials" = {
    text = ''
      username=Moawia
      password=CHANGE_ME
      domain=WORKGROUP
    '';
    mode = "0600";
  };
}
