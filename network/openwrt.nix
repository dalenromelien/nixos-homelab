{config, pkgs, lib, nixvirt, images, ...}:

let
  openwrtImg = images.openWrtImageBuild;
in "${openwrtImg}"
