{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.contabo.wan;
in {
  options.modules.contabo.wan = {
    enable = mkEnableOption "Enable Contabo Cloud WAN interface configuration";

    macAddress = mkOption {
      type = types.str;
      description = "MAC Address of the WAN interface";
    };

    ipAddresses = mkOption {
      type = types.listOf types.str;
      description = "List of IP Addresses on the WAN interface";
    };
  };

  config = mkIf cfg.enable {
    systemd.network.networks."20-wan" = {
      matchConfig = {
        MACAddress = cfg.macAddress;
      };
      address = cfg.ipAddresses;
      routes = [
        {routeConfig.Gateway = "fe80::1";}
        # {routeConfig = {Destination = "62.171.160.1";};}
        # {
        #   routeConfig = {
        #     Gateway = "62.171.160.1";
        #     GatewayOnLink = true;
        #   };
        # }
        # {
        #   routeConfig = {
        #     Destination = "172.16.0.0/12";
        #     Type = "unreachable";
        #   };
        # }
        # {
        #   routeConfig = {
        #     Destination = "192.168.0.0/16";
        #     Type = "unreachable";
        #   };
        # }
        # {
        #   routeConfig = {
        #     Destination = "10.0.0.0/8";
        #     Type = "unreachable";
        #   };
        # }
        # {
        #   routeConfig = {
        #     Destination = "fc00::/7";
        #     Type = "unreachable";
        #   };
        # }
      ];
    };
  };
}
