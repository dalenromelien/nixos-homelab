{ config, pkgs, ...}:

{
  services.nextcloud = {
    enable = true;
    hostName = "nextcloud.dalen-nixos.duckdns.org";
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
  

  security.acme = {
    acceptTerms = true;
    defaults.email = "dalenm.romelien@gmail.com";
    defaults.extraLegoFlags = ["--dns.propagation-wait" "300s"];
  };

  # Wildcard certificate for DuckDNS
  security.acme.certs."dalen-nixos.duckdns.org" = {
    domain = "*.dalen-nixos.duckdns.org";
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
      hostname = "https://auth.dalen-nixos.duckdns.org";
      hostname-backchannel-dynamic = false;
    };
    initialAdminPassword = "e6Wcm0RrtegMEHl";
    sslCertificate = "/var/lib/acme/dalen-nixos.duckdns.org/fullchain.pem";
    sslCertificateKey = "/var/lib/acme/dalen-nixos.duckdns.org/key.pem";
    database.passwordFile = "/etc/nixos/secrets/keycloak-db-pass.txt";
  };


  

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    virtualHosts."auth.dalen-nixos.duckdns.org" = {
      forceSSL = true;
      listen = [
        {
          addr = "192.168.10.165";
          port = 81;
          ssl = true;
        }
      ];

      sslCertificate = "/var/lib/acme/dalen-nixos.duckdns.org/fullchain.pem";
      sslCertificateKey = "/var/lib/acme/dalen-nixos.duckdns.org/key.pem";

      locations."/" = {
        proxyPass = "http://127.0.0.1:8080"; # Keycloak internal HTTP
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-For $remote_addr;
          proxy_set_header X-Forwarded-Host $host;
        '';
      };
    };
  };




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
