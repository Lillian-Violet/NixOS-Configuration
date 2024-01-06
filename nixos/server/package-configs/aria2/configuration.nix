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
      networking.firewall.allowedUDPPorts = [6969 51820];
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
          postUp = ''
            # Mark packets on the wg0 interface
            wg set wg0 fwmark 51820

            # Forbid anything else which doesn't go through wireguard VPN on
            # ipV4 and ipV6
            ${pkgs.iptables}/bin/iptables -A OUTPUT \
              ! -d 192.168.0.0/16 \
              ! -o wg0 \
              -m mark ! --mark $(wg show wg0 fwmark) \
              -m addrtype ! --dst-type LOCAL \
              -j REJECT
            ${pkgs.iptables}/bin/ip6tables -A OUTPUT \
              ! -o wg0 \
              -m mark ! --mark $(wg show wg0 fwmark) \
              -m addrtype ! --dst-type LOCAL \
              -j REJECT
            ${pkgs.iptables}/bin/iptables -I OUTPUT -o lo -p tcp \
              --dport 8112 -m state --state NEW,ESTABLISHED -j ACCEPT
            ${pkgs.iptables}/bin/iptables -I OUTPUT -s 192.168.100.10/24 -d 192.168.100.11/24 \
              -j ACCEPT
          '';
          postDown = ''
            ${pkgs.iptables}/bin/iptables -D OUTPUT \
              ! -o wg0 \
              -m mark ! --mark $(wg show wg0 fwmark) \
              -m addrtype ! --dst-type LOCAL \
              -j REJECT
            ${pkgs.iptables}/bin/ip6tables -D OUTPUT \
              ! -o wg0 -m mark \
              ! --mark $(wg show wg0 fwmark) \
              -m addrtype ! --dst-type LOCAL \
              -j REJECT
          '';

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
