{pkgs, ...}:

  inputs.openwrt-imagebuilder.lib.build {
    inherit pkgs;
    release = "24.10.4";
    target = "x86";
    variant = "64";
    profile = "generic";
    packages = [
      "luci"
      "luci-base"
      "luci-mod-admin-full"
      "luci-theme-bootstrap"
      "luci-app-firewall"
      "luci-app-opkg"
      "luci-ssl"
      "adblock"
      "luci-app-adblock"
      "kmod-tun"
      "ca-certificates"
      "ca-bundle"
      "libustream-openssl"
      "curl"
      "wget-ssl"
      "bash"
      "htop"
      "nano"
      "coreutils"
      "coreutils-base64"
      "tcpdump-mini"
      "bind-dig"
      "ip-full"
    ];

    disabledServices = [];

    files = pkgs.runCommand "image-files" {} ''
      mkdir -p $out/etc/uci-defaults
      cat > $out/etc/uci-defaults/99-custom <<EOF
      uci -q batch << EOI
      set system.@system[0].hostname='nixrouter'
      commit
      EOI
      EOF
     '';
  }
