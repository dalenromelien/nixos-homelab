# in here will go a configuration for an OpenWRT Virtual Machine, that will handle network wide adblocking, Netbird client configuration, DHCP and Local DNS and other firewall rules. 
{ config, pkgs, lib, ... }:

let
  openwrtImage = pkgs.fetchurl {
    url = "https://downloads.openwrt.org/releases/23.05.4/targets/x86/64/openwrt-23.05.4-x86-64-generic-ext4-combined.img.gz";
    sha256 = "<SHA256>";
  };

  openwrtQcow = pkgs.runCommand "openwrt-qcow2" { buildInputs = [ pkgs.qemu ]; } ''
    cp ${openwrtImage} openwrt.img.gz
    gunzip openwrt.img.gz
    qemu-img convert -O qcow2 openwrt.img $out
  '';
in
{
  virtualisation.libvirtd.enable = true;

  # Install XML into libvirt configuration
  environment.etc."libvirt/qemu/openwrt.xml".source =
    ./openwrt.xml;

  # Ensure bridges exist (you may adjust these)
  networking.bridges.br-wan.interfaces = [ "enp1s0" ];
  networking.bridges.br-lan.interfaces = [];

  # Make image available under /var/lib/libvirt/images/
  systemd.tmpfiles.rules = [
    "d /var/lib/libvirt/images 0755 root root -"
    "L+ /var/lib/libvirt/images/openwrt.qcow2 - - - ${openwrtImage}/openwrt.qcow2"
  ];

  # Auto-start the VM on boot
  systemd.services.start-openwrt = {
    description = "Define and start OpenWRT VM";
    after = [ "libvirtd.service" ];
    wants = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.libvirt}/bin/virsh define /etc/libvirt/qemu/openwrt.xml || true
      ${pkgs.libvirt}/bin/virsh start openwrt || true
    '';
  };

}
