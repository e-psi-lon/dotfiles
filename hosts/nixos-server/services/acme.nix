{ config, ... }: {
  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "acme@${config.mainDomain}";
      dnsProvider = "cloudflare";
      server = "https://acme-staging-v02.api.letsencrypt.org/directory"; # remove once install succeeded
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
