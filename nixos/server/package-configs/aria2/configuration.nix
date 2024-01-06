{
  config,
  pkgs,
  ...
}: {
  users.users.aria2.group = "aria2";
  users.groups.aria2 = {};
  users.users.aria2.isSystemUser = true;

  sops.secrets."wg-private".mode = "0440";
  sops.secrets."wg-private".owner = config.users.users.aria2.name;
  containers.aria2 = {
    forwardPorts = [
      {
        containerPort = 6969;
        hostPort = 6969;
        protocol = "udp";
      }
    ];
    bindMounts = {
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
    hostAddress6 = "fc00::1";
    localAddress6 = "fc00::2";
    config = {
      config,
      pkgs,
      ...
    }: {
      system.stateVersion = "unstable";
      networking.firewall.allowedTCPPorts = [6969];
      networking.firewall.allowedUDPPorts = [6969];
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
