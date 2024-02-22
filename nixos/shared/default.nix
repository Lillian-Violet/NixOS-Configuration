{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./locale
    ./packages
  ];
  sops.age.keyFile = ../../../../../../var/secrets/keys.txt;
  sops.secrets."lillian-password".neededForUsers = true;

  users.users.lillian = {
    isNormalUser = true;
    extraGroups = ["sudo" "networkmanager" "wheel" "vboxsf" "docker"];
    shell = pkgs.zsh;
    hashedPasswordFile = config.sops.secrets."lillian-password".path;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGatnsrKMoZSW24Lw4meb6BAgHgeyN/8rUib4nZVT+CB lillian@EDI"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC7+LEQnC/nlYp7nQ4p6hUCqaGiqfsA3Mg8bSy+zA8Fj lillian@GLaDOS"
    ];
  };

  users.mutableUsers = false;

  users.users.root = {
    hashedPassword = "*";
  };
}
