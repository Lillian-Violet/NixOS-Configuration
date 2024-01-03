{
  config,
  pkgs,
  ...
}: {
  #uses port 8989
  services.radarr = {
    enable = true;
  };
}
