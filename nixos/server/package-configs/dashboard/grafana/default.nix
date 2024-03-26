{
  config,
  pkgs,
  ...
}: {
  # grafana configuration
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "grafana.lillianviolet.dev";
      http_port = 2342;
      http_addr = "127.0.0.1";
    };
    provision = {
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "Prometheus";
            type = "prometheus";
            access = "proxy";
            url = "http://localhost:${toString config.services.prometheus.port}";
            isDefault = true;
          }
          # {
          #   name = "Loki";
          #   type = "loki";
          #   access = "proxy";
          #   url = "http://localhost:${config.services.loki.port}";
          #   isDefault = true;
          # }
        ];
      };
    };
  };

  # nginx reverse proxy
  services.nginx.virtualHosts.${config.services.grafana.settings.server.domain} = {
    ## Force HTTP redirect to HTTPS
    forceSSL = true;
    ## LetsEncrypt
    enableACME = true;
    locations."/" = {
      proxyPass = "http://${toString config.services.grafana.settings.server.http_addr}:${toString config.services.grafana.settings.server.http_port}";
      proxyWebsockets = true;
    };
  };
}
