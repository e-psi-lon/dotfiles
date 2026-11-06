{ config, ... }: {
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@${config.mainDomain}";
      dnsResolver = "1.1.1.1:53";
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
