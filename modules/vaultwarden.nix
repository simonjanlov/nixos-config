{ config, lib, pkgs, ... }:
let
  cfg = config.simon.vaultwarden;
  keys = config.deployment.keys;
in
{
  options.simon.vaultwarden =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to host the Vaultwarden secret management service
        '';
      };
    };

  config = lib.mkIf cfg.enable
    {
      services.vaultwarden = {
        enable = true;
        config = {
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;
          ROCKET_WORKERS = 10;
          SIGNUPS_ALLOWED = false;
          DOMAIN = "https://vw.${config.simon.domain.homelab.domain}";
          SMTP_HOST = "smtp.gmail.com";
          SMTP_PORT = 465;
          SMTP_SECURITY = "force_tls";
          SMTP_USERNAME = "simon.janlov@gmail.com";
          SMTP_FROM = "simon.janlov@gmail.com";
          SMTP_FROM_NAME = "Vaultwarden";
          SMTP_SSL = true;
          SMTP_EXPLICIT_TLS = true;
          PASSWORD_ITERATIONS = 2000000;
        };
        environmentFile = keys.vaultwarden-env.path;
        backupDir = "/var/lib/backup-vaultwarden";
      };

      simon.nginx-base.enable = true;

      services.nginx.virtualHosts =
        {
          "vw.${config.simon.domain.homelab.domain}" =
            {
              forceSSL = true;
              enableACME = true;

              locations."/" = {
                proxyPass = "http://${config.services.vaultwarden.config.ROCKET_ADDRESS}:${toString config.services.vaultwarden.config.ROCKET_PORT}";
                proxyWebsockets = true;
              };
            };
        };

      systemd.services.vaultwarden.serviceConfig.SupplementaryGroups = [
        "keys"
      ];
    };
}
