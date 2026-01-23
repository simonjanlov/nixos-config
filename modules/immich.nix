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
        mediaLocation = "/srv/media/immich";
        settings = {
          server.externalDomain = "https://photos.dyn.iikon.se";
          machineLearning.duplicateDetection.maxDistance = "0.05";
        };
        # settings = {
        #   server.externalDomain = "https://share.dyn.iikon.se";
        # };
      };

      services.immich.machine-learning.environment = {
        XDG_CACHE_HOME = "/var/cache/immich";
      };

      services.immich.accelerationDevices = [ "/dev/dri/renderD128" ];
      users.users.immich.extraGroups = [ "video" "render" ];

      systemd.services.immich-server =
        {
          after = [ "immich-secrets-key.service" ];
          wants = [ "immich-secrets-key.service" ];
        };

      simon.backups.paths = [ "${config.services.immich.mediaLocation}" ];

      simon.nginx-base.enable = true;

      services.nginx.virtualHosts =
        {
          "photos.${config.simon.domain.homelab.domain}" =
            {
              forceSSL = true;
              enableACME = true;

              locations."/" = {
                proxyPass = "http://${config.services.immich.host}:${toString config.services.immich.port}";
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

      ## Settings for Immich Public Proxy ##

      # services.nginx.virtualHosts =
      #   {
      #     "share.dyn.iikon.se" =
      #       {
      #         forceSSL = true;
      #         enableACME = true;

      #         locations."/" = {
      #           proxyPass = "http://localhost:${toString config.services.immich-public-proxy.port}";
      #         };
      #       };
      #   };

      # services.immich-public-proxy = {
      #   enable = true;
      #   immichUrl = "http://${config.services.immich.host}:${toString config.services.immich.port}";
      # };
    };
}
