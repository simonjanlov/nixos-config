{ config, lib, ... }:
let
  cfg = config.simon.home-assistant;
in
{
  options.simon.home-assistant =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to host the Home Assistant service
          '';
      };
    };

  config = lib.mkIf cfg.enable
    {
      virtualisation.oci-containers.containers = {
        home-assistant = {
          environment.TZ = config.time.timeZone;
          image = "ghcr.io/home-assistant/home-assistant:2026.2.1";
          extraOptions = [
            "--network=host"
            "--device=/dev/ttyUSB0:/dev/ttyUSB0"
            "--cap-add=NET_ADMIN"
            "--cap-add=NET_RAW"
          ];
          volumes = [
            "home-assistant:/config"
            "/run/dbus:/run/dbus:ro"
          ];
        };
      };

      simon.backups.paths = [ "/var/lib/containers" ];

      simon.nginx-base.enable = true;

      hardware.bluetooth.enable = true;

      services.nginx.virtualHosts =
        {
          "home.${config.simon.domain.homelab.domain}" =
            {
              forceSSL = true;
              enableACME = true;

              extraConfig = ''
                proxy_buffering off;
                '';

              locations."/" = {
                proxyPass = "http://127.0.0.1:8123";
                proxyWebsockets = true;
              };
            };
        };
    };
}
