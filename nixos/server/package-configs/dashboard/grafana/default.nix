{
  config,
  pkgs,
  ...
}: {
  # grafana configuration
  services.grafana = {
    enable = true;
    domain = "grafana.lillianviolet.dev";
    http_port = 2342;
    http_addr = "127.0.0.1";
    provision = {
      datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://localhost:${config.services.prometheus.port}";
          isDefault = true;
        }
        {
          name = "Loki";
          type = "loki";
          access = "proxy";
          url = "http://localhost:${config.services.loki.port}";
          isDefault = true;
        }
      ];
    };
  };

  # nginx reverse proxy
  services.nginx.virtualHosts.${config.services.grafana.domain} = {
    ## Force HTTP redirect to HTTPS
    forceSSL = true;
    ## LetsEncrypt
    enableACME = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.grafana.port}";
      proxyWebsockets = true;
    };
  };
}
