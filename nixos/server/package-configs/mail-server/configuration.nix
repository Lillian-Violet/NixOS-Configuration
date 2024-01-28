{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  sops.secrets."mailpass".mode = "0440";
  sops.secrets."mailpass".owner = config.users.users.virtualMail.name;

  #Fix for the dovecot update
  services.dovecot2.sieve.extensions = ["fileinto"];

  mailserver = {
    enable = true;
    enableImap = true;
    enableSubmission = true;
    fqdn = "mail.gladtherescake.eu";
    domains = [
      "nextcloud.gladtherescake.eu"
      "akkoma.gladtherescake.eu"
      "social.gladtherescake.eu"
      "lillianviolet.dev"
      "git.lillianviolet.dev"
    ];

    loginAccounts = {
      "no-reply@nextcloud.gladtherescake.eu" = {
        hashedPasswordFile = config.sops.secrets."mailpass".path;
      };
      "no-reply@akkoma.gladtherescake.eu" = {
        hashedPasswordFile = config.sops.secrets."mailpass".path;
      };
      "no-reply@social.gladtherescake.eu" = {
        hashedPasswordFile = config.sops.secrets."mailpass".path;
      };
      "info@lillianviolet.dev" = {
        hashedPasswordFile = config.sops.secrets."mailpass".path;
        aliases = [
          "@lillianviolet.dev"
        ];
        catchAll = [
          "lillianviolet.dev"
        ];
      };
      "no-reply@git.lillianviolet.dev" = {
        hashedPasswordFile = config.sops.secrets."mailpass".path;
      };
    };

    mailboxes = {
      All = {
        auto = "subscribe";
        specialUse = "All";
      };
      Archive = {
        auto = "subscribe";
        specialUse = "Archive";
      };
      Drafts = {
        auto = "subscribe";
        specialUse = "Drafts";
      };
      Junk = {
        auto = "subscribe";
        specialUse = "Junk";
      };
      Sent = {
        auto = "subscribe";
        specialUse = "Sent";
      };
      Trash = {
        auto = "no";
        specialUse = "Trash";
      };
    };

    rejectRecipients = [
      "no-reply@nextcloud.gladtherescake.eu"
      "no-reply@akkoma.gladtherescake.eu"
      "no-reply@social.gladtherescake.eu"
      "no-reply@git.lillianviolet.dev"
    ];
    certificateScheme = "acme-nginx";
    certificateDomains = [
      "imap.lillianviolet.dev"
      "mail.lillianviolet.dev"
      "pop3.lillianviolet.dev"
      "lillianviolet.dev"
    ];
  };
}
