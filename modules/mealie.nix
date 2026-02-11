{ config, lib, pkgs, ... }:
let
  cfg = config.simon.mealie;
  keys = config.deployment.keys;
in
{
  options.simon.mealie =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to host the Mealie recipe service
          '';
      };
    };
  config = lib.mkIf cfg.enable
    {
      services.mealie = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 4537;
        settings = {
          TZ = config.time.timeZone;
          TOKEN_TIME = 24 * 180;
          SMTP_HOST = "smtp.gmail.com";
          SMTP_FROM_EMAIL = "simon.janlov@gmail.com";
          SMTP_USER = "simon.janlov@gmail.com";
          OPENAI_BASE_URL = "http://${config.services.ollama.host}:${toString config.services.ollama.port}/v1";
          OPENAI_API_KEY = "12345";
          OPENAI_MODEL = "jobautomation/OpenEuroLLM-Swedish:latest";
          OPENAI_REQUEST_TIMEOUT = 400;
        };
        credentialsFile = "${keys.mealie-secrets.path}";

        # PostgreSQL instead of the default SQLite
        database.createLocally = true;
      };

      systemd.services.mealie =
        {
          after = [ "mealie-secrets-key.service" ];
          wants = [ "mealie-secrets-key.service" ];
        };

      simon.nginx-base.enable = true;

      services.nginx.virtualHosts =
        {
          "recipes.${config.simon.domain.homelab.domain}" =
            {
              forceSSL = true;
              enableACME = true;

              locations."/" = {
                proxyPass = "http://${config.services.mealie.listenAddress}:${toString config.services.mealie.port}";
                proxyWebsockets = true;
                extraConfig = ''
                  client_max_body_size 50M;
                '';
              };
            };
        };

    };
}
