{
  config,
  pkgs,
  ...
}: {
  services.dex = {
    enable = true;
    # You can add secret files here
    environmentFile = null;
    settings = {
      # External url
      issuer = "http://127.0.0.1:5556/dex";
      storage = {
        type = "postgres";
        config.host = "/var/run/postgres";
      };
      web = {
        http = "127.0.0.1:5556";
      };
      enablePasswordDB = true;
      staticClients = [
        {
          id = "oidcclient";
          name = "Client";
          redirectURIs = ["https://example.com/callback"];
          secretFile = "/etc/dex/oidcclient"; # The content of `secretFile` will be written into to the config as `secret`.
        }
      ];
    };
  };
}
