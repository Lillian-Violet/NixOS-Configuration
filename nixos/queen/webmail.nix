{
  config,
  pkgs,
  lib,
  ...
}: {
  # TODO: Figure out how to create packages for some plugins for roundcube!
  # https://packagist.org/search/?query=roundcube
  # https://discourse.nixos.org/t/roundcube-with-plugins/28292/7
  services.roundcube = {
    enable = true;
    package = pkgs.roundcube.withPlugins (
      plugins: [
        plugins.contextmenu
        plugins.carddav
        plugins.custom_from
        plugins.persistent_login
        plugins.thunderbird_labels
      ]
    );
    plugins = [
      "contextmenu"
      "carddav"
      "custom_from"
      "persistent_login"
      "thunderbird_labels"
    ];

    # this is the url of the vhost, not necessarily the same as the fqdn of
    # the mailserver
    hostName = "webmail.lillianviolet.dev";
    extraConfig = ''
      # starttls needed for authentication, so the fqdn required to match
      # the certificate
      $config['smtp_server'] = "tls://${config.mailserver.fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };
}
