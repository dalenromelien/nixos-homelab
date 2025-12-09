{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
        
    openwrt-imagebuilder = {
      url = "github:astro/nix-openwrt-imagebuilder";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, openwrt-imagebuilder, nixvirt, ... }@inputs: {
    
    packages.x86_64-linux.my-router = import ./network/openwrt.nix {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      inherit inputs;
      openwrt-imagebuilder = openwrt-imagebuilder.override {
        buildRoot = "/var/tmp/openwrt-build";
      };
    };
    
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
        ./network/nixvirt.nix
      ];
    };
  };
}
