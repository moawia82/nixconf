{
  description = " NixOS Configuration for Remote Access Server\;

 inputs = {
 nixpkgs.url = \github:NixOS/nixpkgs/nixos-23.11\;
 sops-nix.url = \github:Mic92/sops-nix\;
 };

 outputs = { self, nixpkgs, sops-nix, ... }: {
 nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
 system = \x86_64-linux\;
 modules = [
 ./modules/hardware-configuration.nix
 ./modules/base-system.nix
 ./modules/networking.nix
 ./modules/users.nix 
 ./modules/services.nix
 ./modules/power-management.nix
 sops-nix.nixosModules.sops
 ./modules/secrets.nix
 ];
 };
 };
}
