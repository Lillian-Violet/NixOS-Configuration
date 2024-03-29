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
    path = with pkgs; [jq coreutils udisks bash util-linux toybox auto-mount steam];
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.auto-mount}/bin/auto-mount add %i";
      ExecStop = "${pkgs.auto-mount}/bin/auto-mount remove %i";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
