{config, pkgs, ...}:
{
  
  
  services.step-ca = {
    enable = true;
    openFirewall = true;
    address = "0.0.0.0";
    port = 9000;

    settings = {
	    root = "/run/secrets/step-ca/root_ca.crt";
	    crt = "/run/secrets/step-ca/intermediate_ca.crt";
	    key = "/run/secrets/step-ca/intermediate_ca_key";
	    address = ":9000";
	    dnsNames = ["ca.dalen-homelab.com"];
	    logger = {format = "text";};
	    db = {
	      type = "badgerv2";
              dataSource = "/var/lib/smallstep/db";
	    };

	    authority = {
	      provisioners = [
	        {
	          type = "ACME";
	          name = "acme";
	          claims = {
		          disableRenewal = false;
		          allowRenewalAfterExpiry = false;
		          disableSmallstepExtensions = false;
	          };
	        }
	      ];

	      tls = {
	        cipherSuites = ["TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256" "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"];
	        minVersion = 1.2;
                maxVersion = 1.3;
	        renegotiation = false;
	      };
	      commonName = "Step Online CA";
      };
    };

    intermediatePasswordFile = "/run/secrets/step-ca/ca-password.txt";
 };
}
