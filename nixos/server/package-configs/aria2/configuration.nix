{
  config,
  pkgs,
  ...
}: {
  users.users.aria2.group = "aria2";
  users.groups.aria2 = {};
  users.users.aria2.isSystemUser = true;

  services.aria2 = {
    enable = true;
    downloadDir = "/var/lib/media";
    rpcListenPort = 6969;
  };
}
