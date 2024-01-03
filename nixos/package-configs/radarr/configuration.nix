{
  config,
  pkgs,
  ...
}: {
  #uses port 7878
  services.radarr = {
    enable = true;
  };
}
