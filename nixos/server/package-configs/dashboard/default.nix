{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./grafana
    #./loki
    #./prometheus
  ];
}
