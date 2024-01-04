{
  config,
  pkgs,
  ...
}: {
  sops.secrets."wg-private".mode = "0440";
  sops.secrets."wg-private".owner = config.users.users.aria2.name;
  containers.aria2 = {
    forwardPorts = {
      hostPort = 6969;
      protocol = "tcp";
    };
    bindmounts = {
      "/var/lib/media" = {
        hostPath = "/var/lib/media";
        isReadOnly = false;
      };
      "/var/lib/wg/private-key" = {
        hostPath = config.sops.secrets."wg-private".path;
        isReadOnly = true;
      };
    };
    autoStart = true;
    privateNetwork = true;
    hostAddress = "192.168.100.10";
    localAddress = "192.168.100.11";
    config = {
      config,
      pkgs,
      ...
    }: {
      users.users = {
        aria2.extraGroups = ["jellyfin" "nextcloud"];
      };
      services.aria2 = {
        enable = true;
        downloadDir = "/var/lib/media";
        rpcListenPort = 6969;
      };
      networking.wg-quick.interfaces = {
        wg0 = {
          address = ["10.2.0.2/32"];
          dns = ["10.2.0.1"];
          privateKeyFile = "/var/lib/wg/private-key";

          peers = [
            {
              publicKey = "7A19/lMrfmpFZARivC7FS8DcGxMn5uUq9LcOqFjzlDo=";
              allowedIPs = ["0.0.0.0/0"];
              endpoint = "185.159.158.182:51820";
              persistentKeepalive = 25;
            }
          ];
        };
      };
    };
  };
}
