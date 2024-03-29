Original source: https://git.lillianviolet.dev/Lillian-Violet/NixOS-Config

# NixOS-Config

The configuration of different NixOS hosts using flakes and home-manager. It is assumed you have already installed NixOS and git to your system (note: git is not installed by default with the NixOS image, you can grab it with ``nix-shell -p git``), this configuration does not have image artifacts nor can it create them.

## Building and deploying the configuration

If you do not have my private age key, the first step is to add your age keyfile to the /var/secrets folder with the name "keys.txt", in my case an age private key. If you don't have have an age private key you can generate one with the command

``age-keygen -o ~/.config/sops/age/keys.txt`` and copying this file to ``/var/secrets/``

**Note: make sure this key is not readable by normal users, I made it owned by root, and gave the file 400 (read only for user) permissions. eg: ``chown 400 /var/secrets/keys.txt``**

if you don't want to use [sops](https://github.com/Mic92/sops-nix) secret management remove the import from the configuration files; the import can be found under
``hosts/shared/default.nix``

Upon any of the above changes; also remove/replace the secret files, they can be found under the host configuration folders in
``hosts/<hostname>/secrets/sops.yaml``

For the hosts EDI and GLaDOS, [lanzaboot](https://github.com/nix-community/lanzaboote) has to be disabled (and re-enabled if you want secure boot after install). You can first replace enabling lanzaboot with systemd-boot. You can do this by commenting out the lanzaboot configuration, and replace the line

``boot.loader.systemd-boot.enable = lib.mkForce false;`` with ``boot.loader.systemd-boot.enable = true``

To turn secure boot back on again you can look at the [lanzaboot](https://github.com/nix-community/lanzaboote) repository and follow the install steps.

Then run this command with your cloned github repo (I put mine in /etc/nixos):

``sudo nixos-rebuild --flake .#<hostname> switch``

This should rebuild the OS with all programs and settings defined as in the configuration.

## Updating the flake lock

In order to have updated packages you will have to update the flake.lock file, this can be done by running the following command in the repository:

``nix flake update``  

Please note that you should commit and push after you do this. It is therefore advisable to do this not in your deployment directory, but your local dev environment. Not commiting the files will dirty your git history, which can have unintended consequences as nix flakes work via git.

## Testing the evaluation

To test if your build succeeds the basic checks and can start building the artifacts, you can run the following command:

``nix flake check``

Note: this does not build the full configuration, and errors might still happen in deployment, especially for dependencies that rely on external services like webservers to be called. For obvious reasons the test building does not actually pull in all the artifacts, and does not make external calls aside from to the package files (You will need a built nix store, or a connection to the git repository that hosts your packages, like an internet connection to github, to make the test run)

## Technical details

### [Home manager](https://github.com/nix-community/home-manager)
Home manager is imported as a module within the global configuration, it is therefor not needed to build home-manager packages separately in this configuration. On multi user systems it might be useful to pull the home-manager configurations from separate repos for different users, so you don't have to give your users access to the global configuration.

### [Sops](https://github.com/Mic92/sops-nix)
The secrets are managed in sops files within the hosts folders, there is only one sops file per host, but this can be changed quite easily. The command to edit the sops file is as follows:

``nix-shell -p sops --run "sops ./nixos/hosts/<hostname>/secrets/sops.yaml"``

This requires your system to have the keyfile available for sops to use, by default sops looks in the sops/age folder in your user folder for a keys.txt file with the private key. You can change this behaviour by setting the **\$SOPS_AGE_KEY_FILE** environment variable, or setting the **\$SOPS_AGE_KEY** environment variable to the key itself.