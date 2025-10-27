{ config, lib, ... }:
let
  cfg = config.simon.immich;
  keys = config.deployment.keys;
in
{
  options.simon.immich =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to enable the immich photo and video management service
          '';
      };
    };

  config = lib.mkIf cfg.enable
    {
      services.immich = {
        enable = true;
        openFirewall = true;
        mediaLocation = "/srv/media/immich";
        secretsFile = "${keys.immich-secrets.path}";
        settings = {
          server.externalDomain = "https://photos.dyn.iikon.se";
        };
      };

      services.immich.machine-learning.environment = {
        XDG_CACHE_HOME = "/var/cache/immich";
      };

      services.immich.accelerationDevices = [ "/dev/dri/renderD128" ];
      users.users.immich.extraGroups = [ "video" "render" ];

      simon.nginx-base.enable = true;

      services.nginx.virtualHosts =
        {
          "photos.dyn.iikon.se" =
            {
              forceSSL = true;
              enableACME = true;

              locations."/" = {
                proxyPass = "http://[::1]:${toString config.services.immich.port}";
                proxyWebsockets = true;

                extraConfig = ''
                  client_max_body_size 50000M;
                  proxy_read_timeout   600s;
                  proxy_send_timeout   600s;
                  send_timeout         600s;
                  '';
              };
            };
        };
    };
}
