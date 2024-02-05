{
  inputs,
  outputs,
  config,
  pkgs,
  ...
}: {
  users.users.aria2.group = "aria2";
  users.groups.aria2 = {};
  users.users.aria2.isSystemUser = true;

  sops.secrets."rpcSecret".mode = "0440";
  sops.secrets."rpcSecret".owner = config.users.users.aria2.name;

  services.aria2 = {
    enable = true;
    downloadDir = "/var/lib/media";
    rpcListenPort = 6969;
    rpcSecretFile = config.sops.secrets."rpcSecret".path;
  };
}
