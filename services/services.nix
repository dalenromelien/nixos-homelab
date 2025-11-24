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
  ];
  
  services.step-ca = {
    enable = true;
    openFirewall = true;
    port = 9000;
    address = "0.0.0.0";
    
    settings = {
      dnsNames = ["nixos.dalen-homelab.com"];
      root = "/etc/smallstep/certs/root_ca.crt";
      crt = "/etc/smallstep/certs/intermediate_ca.crt";
      key = "/etc/smallstep/secrets/intermediate_ca_key";
    };
    intermediatePasswordFile = "/etc/nixos/secrets/ca-password.txt";
  };
  
  security.acme = {
    acceptTerms = true;   
    defaults.email = "dalenm.romelien@gmail.com";
    certs."dalen-homelab.com" = {
      server = "https://nixos.dalen-homelab.com/acme/acme-directory";
      email = "dalenm.romelien@gmail.com";
      listenHTTP = "127.0.0.1:0";
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
  
  services.nginx = {
    enable = true;
    virtualHosts."nixos.dalen-homelab.com".forceSSL = true;  # This enforces SSL across all services
    virtualHosts."nixos.dalen-homelab.com".enableACME = true; # Enable ACME for all services
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
