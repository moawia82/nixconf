# Simplified Secrets Configuration (without sops for now)
{ config, ... }:

{
  # For now, we'll disable sops and use direct secrets
  # This is temporary until we resolve the sops dependency issue
  
  # Create basic directories for secrets
  systemd.tmpfiles.rules = [
    "d /run/secrets 0755 root root -"
  ];
}