{ config, lib, pkgs, ... }:

let
  cfg = config.simon.backups;

  inherit (lib)
    mkOption
    mkMerge
    mkIf
    types;
in
{
  options.simon.backups =
    {
      enable = mkOption {
        default = builtins.length cfg.paths > 0;
        description = ''
          Whether to enable backups for this host.
        '';
      };
      paths = mkOption {
        default = [];
        type = types.listOf types.path;
        description = ''
          List of paths to backup.
        '';
      };
      exclude = mkOption {
        default = [];
        type = types.listOf types.path;
        description = ''
          List of paths to exclude.
        '';
      };
      time = mkOption {
        default = "11:00";
        type = types.str;
        description = ''
          What time to run the backup.
        '';
      };
      enablePostgresqlBackup = mkOption {
        default = config.services.postgresql.enable;
        type = types.bool;
        description = ''
          Whether to backup PostgreSQL database.
        '';
      };
      includePostgresqlBackup = mkOption {
        default = cfg.enablePostgresqlBackup;
        type = types.bool;
        description = ''
          Whether to add the PostgreSQL backup location to the list of backup paths.
        '';
      };
    };

  config = mkMerge [
    (mkIf cfg.enable {
      services.restic.backups =
        {
          gdrive = mkMerge [
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
              };
            }
            # If current system is the deployment host
            (mkIf config.simon.deployment-tools.enable {
              passwordFile = "/home/simon/.keys/restic-password";
              rcloneConfigFile = "/home/simon/.config/rclone/rclone.conf";
            })
            # Else
            (mkIf (!config.simon.deployment-tools.enable) {
              passwordFile = config.deployment.keys.restic-password.path;
              rcloneConfigFile = config.deployment.keys."rclone.conf".path;
            })
          ];
        };
    })

    (mkIf cfg.enablePostgresqlBackup {
      services.postgresqlBackup.enable = true;
    })

    (mkIf cfg.includePostgresqlBackup {
      simon.backups.paths = [ "${config.services.postgresqlBackup.location}" ];
    })
  ];
}
