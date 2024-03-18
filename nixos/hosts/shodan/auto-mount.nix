{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [auto-mount];

  services.udev.extraRules = ''
    KERNEL=="sd[a-z]|sd[a-z][0-9]", ACTION=="add", RUN+="/run/current-system/sw/bin/systemctl start --no-block external-drive-mount@%k.service"
    KERNEL=="sd[a-z]|sd[a-z][0-9]", ACTION=="remove", RUN+="/run/current-system/sw/bin/systemctl stop --no-block external-drive-mount@%k.service"
    KERNEL=="mmcblk0|mmcblk0p[0-9]", ACTION=="add", RUN+="/run/current-system/sw/bin/systemctl start --no-block external-drive-mount@%k.service"
    KERNEL=="mmcblk0|mmcblk0p[0-9]", ACTION=="remove", RUN+="/run/current-system/sw/bin/systemctl stop --no-block external-drive-mount@%k.service"
    KERNEL=="nvme0n1p9|nvme0n1p1[0-9]", ACTION=="add", RUN+="/run/current-system/sw/bin/systemctl start --no-block external-drive-mount@%k.service"
    KERNEL=="nvme0n1p9|nvme0n1p1[0-9]", ACTION=="remove", RUN+="/run/current-system/sw/bin/systemctl stop --no-block external-drive-mount@%k.service"
  '';
  systemd.services.auto-mount = {
    enable = true;
    description = "Mount External Drive on %i";
    unitConfig = {
    };
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/automount add %i";
      ExecStop = "/run/current-system/sw/bin/automount remove %i";
      RemainAfterExit = true;
    };
    wantedBy = ["multi-user.target"];
  };
}
