{config, pkgs, lib, ...}:
{
  services.step-ca = {
    enable = true;
    openFirewall = true;
    address = "0.0.0.0";
    port = 9000;

    settings = {
    	root = config.sops.secrets."step-ca/root-ca-crt".path;
    	crt = config.sops.secrets."step-ca/intermediate-ca-crt".path;
    	key = config.sops.secrets."step-ca/intermediate-ca-key".path;
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

	# systemd unit expects the password file at `${CREDENTIALS_DIRECTORY}/intermediate_password`
	intermediatePasswordFile = config.sops.secrets."step-ca/password".path;
	};

	# Ensure persistent directories for step-ca runtime data exist with correct ownership.
	systemd.tmpfiles.rules = lib.mkForce (lib.concatLists [
		[
			# directory, mode, user, group, age
			"d /var/lib/step-ca 0750 step-ca step-ca -"
			"d /var/lib/step-ca/db 0750 step-ca step-ca -"
			"d /var/lib/step-ca/secrets 0700 step-ca step-ca -"
			"d /var/lib/step-ca/certs 0755 step-ca step-ca -"
		]
	]);
}
