{ config, ... }: {
  
  sops.secrets.cloudflare-acme-credentials = {
    sopsFile = config.paths.secretsDir + "/cloudflare-dns.txt";
    format = "binary";
  };
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@${config.mainDomain}";
      dnsProvider = "cloudflare";
      credentialFiles = {
        "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare-acme-credentials".path;
      };
    };

    certs = {
      ${config.mainDomain} = {
        extraDomainNames = [ "*.${config.mainDomain}" ];
      };

      ${config.mainInternalDomain} = {
        extraDomainNames = [
          "*.${config.mainInternalDomain}"
        ];
      };
    };
  };
}
