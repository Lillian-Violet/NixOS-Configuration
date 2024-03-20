{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  services.udev.extraRules = ''
    KERNEL=="sd[a-z]|sd[a-z][0-9]", ACTION=="add", RUN+="${pkgs.systemd}/bin/systemctl start --no-block external-drive-mount@%k.service"
    KERNEL=="sd[a-z]|sd[a-z][0-9]", ACTION=="remove", RUN+="${pkgs.systemd}/bin/systemctl stop --no-block external-drive-mount@%k.service"
    KERNEL=="mmcblk0|mmcblk0p[0-9]", ACTION=="add", RUN+="${pkgs.systemd}/bin/systemctl start --no-block external-drive-mount@%k.service"
    KERNEL=="mmcblk0|mmcblk0p[0-9]", ACTION=="remove", RUN+="${pkgs.systemd}/bin/systemctl stop --no-block external-drive-mount@%k.service"
    KERNEL=="nvme0n1p9|nvme0n1p1[0-9]", ACTION=="add", RUN+="${pkgs.systemd}/bin/systemctl start --no-block external-drive-mount@%k.service"
    KERNEL=="nvme0n1p9|nvme0n1p1[0-9]", ACTION=="remove", RUN+="${pkgs.systemd}/bin/systemctl stop --no-block external-drive-mount@%k.service"
  '';
  systemd.services."external-drive-mount@" = {
    path = with pkgs; [jq coreutils udisks bash];
    enable = true;
    description = "Mount External Drive on %i";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "/run/current-system/sw/bin/automount add %i";
      ExecStop = "/run/current-system/sw/bin/automount remove %i";
    };
  };
}
