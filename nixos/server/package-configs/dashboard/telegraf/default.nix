{
  inputs,
  lib,
  config,
  pkgs,
  user,
  ...
}: {
  services.telegraf = {
    enable = true;
    extraConfig = {
      agent = {
        interval = "10s";
        round_interval = true;
        metric_batch_size = 1000;
        metric_buffer_limit = 10000;
        collection_jitter = "0s";
        flush_interval = "10s";
        flush_jitter = "0s";
        precision = "";
        debug = false;
        quiet = false;
        logfile = "";
        hostname = "queen";
        omit_hostname = false;
      };
      inputs = {
        cpu = {
          percpu = true;
          totalcpu = true;
          collect_cpu_time = false;
          report_active = false;
          core_tags = false;
        };
        disk = {
          ignore_fs = ["tmpfs" "devtmpfs" "devfs" "overlay" "aufs" "squashfs"];
        };
        diskio = {};
        kernel = {};
        mem = {};
        system = {};
      };
      outputs = {
        influxdb_v2 = {
          database = "telegraf";
          urls = ["localhost:8086"];
        };
      };
    };
  };

  services.influxdb.enable = true;
}
