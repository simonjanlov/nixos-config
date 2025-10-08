{ config, lib, pkgs, ... }:

let
  cfg = config.simon.backups;

  inherit (lib)
    mkOption
    types;
in
{
  options.simon.backups =
    {
      enable = mkOption {
        default = builtins.length cfg.paths > 0;
        description = ''Whether to enable backups for this host'';
      };
      paths = mkOption {
        default = [];
        type = types.listOf types.path;
        description = ''List of paths to backup'';
      };
      exclude = mkOption {
        default = [];
        type = types.listOf types.path;
        description = ''List of paths to exclude'';
      };
      time = mkOption {
        default = "11:00";
        type = types.str;
        description = ''What time to run the backup'';
      };
    };

  config = lib.mkIf cfg.enable
    {
      services.restic.backups = {
        gdrive = lib.mkMerge [
          {
            exclude = cfg.exclude;
            initialize = true;
            paths = cfg.paths;
            pruneOpts = [
              "--keep-daily 7"
              "--keep-weekly 5"
              "--keep-monthly 12"
              "--keep-yearly 3"
            ];
            rcloneOptions = {
              checksum = true;
              transfers = "30";
            };
            repository = "rclone:gdrive:${config.networking.hostName}";
            # runCheck = true;
            # checkOpts = [ "--read-data-subset=10%" ];
            timerConfig = {
              OnCalendar = cfg.time;
              # OnUnitActiveSec = "300s"; # For testing
            };
          }

          # If current system is the deployment host
          (lib.mkIf config.simon.deployment-tools.enable {
            passwordFile = "/home/simon/.keys/restic-password";
            rcloneConfigFile = "/home/simon/.config/rclone/rclone.conf";
          })
          # Else
          (lib.mkIf (!config.simon.deployment-tools.enable) {
            passwordFile = config.deployment.keys.restic-password.path;
            rcloneConfigFile = config.deployment.keys."rclone.conf".path;
          })
        ];
      };
    };
}
