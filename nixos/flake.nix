{
  description = "NixOS Configuration for Windows Users - Secure Remote Access";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { nixpkgs, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # System hardware configuration (auto-generated)
        ./hardware-configuration.nix
        
        # Our modular configuration
        ./modules/base-system.nix
        ./modules/networking.nix  
        ./modules/services.nix
        ./modules/users.nix
        ./modules/power-management.nix
        
        # Fallback secrets for testing (replace with secrets.nix when SOPS is set up)
        ./modules/secrets-fallback.nix
      ];
    };
  };
}
