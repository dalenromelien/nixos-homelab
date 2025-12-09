{ config, pkgs, lib, inputs, ... }:

{
  virtualisation.libvirtd.enable = true;
  users.users.dalen.extraGroups = [ "libvirtd" ];
  
  # Force evaluation and show path
  warnings = [
    "OpenWRT image path: ${inputs.self.packages.x86_64-linux.my-router}"
  ];
}
