{ config, pkgs, ...}:

{
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.dalen-homelab.com";
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminpassFile = "/etc/nixos/secrets/nextcloud-admin-pass.txt";
    };
    https = true;
  };
  
  networking.firewall.allowedTCPPorts = [
    80
    443
    9000
  ];
  
  services.nginx = {
    enable = true;
  };

  # Create webroot for ACME http-01 challenges
  systemd.tmpfiles.rules = pkgs.lib.mkForce (pkgs.lib.concatLists [
    [
      "d /var/www/acme-challenges 0755 acme acme -"
      "d /var/www/acme-challenges/nextcloud 0755 acme acme -"
      "d /var/www/acme-challenges/nextcloud/.well-known 0755 acme acme -"
      "d /var/www/acme-challenges/nextcloud/.well-known/acme-challenge 0755 acme acme -"
    ]
  ]);

  security.acme = {
    acceptTerms = true;
    defaults = {
      server = "https://ca.dalen-homelab.com:9000/acme/admin/directory";
      email = "dalenm.romelien@gmail.com";
    };

    # ACME cert for Nextcloud using http-01 (webroot)
    certs."nextcloud.dalen-homelab.com" = {
      webroot = "/var/www/acme-challenges/nextcloud";
    };
  };

#  services.keycloak = {
#    enable = true;
#    database = {
#      type = "postgresql";
#      createLocally = true;
#      username = "keycloak";
#      passwordFile = "/etc/nixos/secrets/keycloak-adminpass.txt";
#    };
#    settings = {
#      hostname = "auth.dalen-homelab.com";
#      http-relative-path = "/cloak";
#      
#    };
#  };

#
# 
#  services.netbird = {
#    enable = true;
    
#    server = {
#      enable = true;
#      domain = "netbird.dalen-homelab.com";
#      enableNginx = true;
#      dashboard = {
#        enable = true;
#        settings = {
#          AUTH_AUTHORITY = 
#        }
#      }
#      coturn = {
#        enable = true;
#        passwordFile = "/etc/nixos/secrets/netbird-admin-pass.txt";
#      };
#      management = {
#        oidcConfigEndpoint = "https://auth.dalen-homelab.com/cloak/realms/master/.well-known/openid-configuration";      
#        settings.TURNConfig = {
#          Turns = [
#            {
#              Proto = "udp";
#               URI = "turn:netbird.dalen-homelab.com:3478";
#               Username = "netbird";
#               Password._secret = "/etc/nixos/secrets/netbird-admin-pass.txt";
#            }
#          ];
#        };
#      };
#    };
#  };
}
