{
  disko.devices = {
    disk = {
      vdb = {
        device = "/dev/disk/by-path/pci-0000:71:00.0-nvme-1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                # disable settings.keyFile if you want to use interactive password entry
                #passwordFile = "/tmp/secret.key"; # Interactive
                settings = {
                  allowDiscards = true;
                  keyFile = "/tmp/secret.key";
                };
                #additionalKeyFiles = ["/tmp/additionalSecret.key"];
                content = {
                  root = {
                    name = "root";
                    end = "-1G";
                    content = {
                      type = "filesystem";
                      format = "bcachefs";
                      mountpoint = "/";
                    };
                  };
                  encryptedSwap = {
                    size = "10M";
                    content = {
                      type = "swap";
                      randomEncryption = true;
                    };
                  };
                  plainSwap = {
                    size = "100%";
                    content = {
                      type = "swap";
                      resumeDevice = true; # resume from hiberation from this device
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
