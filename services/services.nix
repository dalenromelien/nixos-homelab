{ config, pkgs, ...}:

{
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.dalen-homelab.duckdns.org";
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
    8080
  ];
  
  services.nginx = {
    enable = true;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "dalenm.romelien@gmail.com";
  };

  # Wildcard certificate for DuckDNS
  security.acme.certs."dalen-homelab.duckdns.org" = {
    domain = "*.dalen-homelab.duckdns.org";
    dnsProvider = "duckdns";
    credentialFiles = {
      DUCKDNS_TOKEN_FILE = "/etc/nixos/secrets/duckdns.ini";
    };
    dnsPropagationCheck = true;

    # Useful if using nginx, caddy, or specific service groups
    group = "nginx";
  };

  services.keycloak = {
    enable = true;
    settings = {
      hostname = "auth.dalen-homelab.duckdns.org";
      hostname-backchannel-dynamic = true;
      proxy-headers = "xforwarded";
    };
    initialAdminPassword = "password"; # change on first login
    sslCertificate = "/var/lib/acme/dalen-homelab.duckdns.org/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/dalen-homelab.duckdns.org/key.pem";
    database.passwordFile = "/etc/nixos/secrets/keycloak-db-pass.txt";
    
  };

 # services.nginx.virtualHosts."auth.dalen-homelab.duckdns.org" = {
 #   enableACME = false; # keycloak using wildcard cert instead
 #   forceSSL = true;

 #   sslCertificate = "/var/lib/acme/dalen-homelab.duckdns.org/fullchain.pem";
 #   sslCertificateKey = "/var/lib/acme/dalen-homelab.duckdns.org/key.pem";

 #   locations."/" = {
 #     proxyPass = "http://127.0.0.1:8080/cloak/";
 #     proxyWebsockets = true;
 #   };
 # };



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
