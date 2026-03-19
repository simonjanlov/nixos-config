{ config, lib, ... }:
let
  cfg = config.simon.collabora;
in
{
  options.simon.collabora =
    {
      enable = lib.mkOption {
        default = config.simon.nextcloud.enable;
        example = false;
        description = ''
          Whether to enable the Collabora office suite.
        '';
      };
    };

  config = lib.mkIf cfg.enable
    {
      services.collabora-online = {
        enable = true;
        settings = {
          ssl = {
            enable = false;
            termination = true;
          };

          # Listen on loopback interface only, and accept requests from ::1
          net = {
            listen = "loopback";
            post_allow.host = ["::1"];
          };

          # Restrict to loading documents from WOPI Host nextcloud.example.com
          storage.wopi = {
            "@allow" = true;
            host = [ "${config.services.nextcloud.hostName}" ];
          };

          server_name = "collabora.${config.simon.domain.homelab.domain}";
        };
      };

      simon.nginx-base.enable = true;

      services.nginx.virtualHosts =
        {
          "collabora.${config.simon.domain.homelab.domain}" =
            {
              forceSSL = true;
              enableACME = true;

              locations."/" = {
                proxyPass = "http://[::1]:${toString config.services.collabora-online.port}";
                proxyWebsockets = true;
              };
            };
        };

      # Systemd service that sets Nextcloud config values for Collabora using the occ CLI

      systemd.services.nextcloud-config-collabora =
        let
          inherit (config.services.nextcloud) occ;

          wopi_url = "http://[::1]:${toString config.services.collabora-online.port}";
          public_wopi_url = "https://collabora.${config.simon.domain.homelab.domain}";
          wopi_allowlist = lib.concatStringsSep "," [
            "127.0.0.1"
            "::1"
          ];
        in {
          wantedBy = ["multi-user.target"];
          after = ["nextcloud-setup.service" "coolwsd.service"];
          requires = ["coolwsd.service"];
          script = ''
            ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_url --value ${lib.escapeShellArg wopi_url}
            ${occ}/bin/nextcloud-occ config:app:set richdocuments public_wopi_url --value ${lib.escapeShellArg public_wopi_url}
            ${occ}/bin/nextcloud-occ config:app:set richdocuments wopi_allowlist --value ${lib.escapeShellArg wopi_allowlist}
            ${occ}/bin/nextcloud-occ richdocuments:setup
          '';
          serviceConfig = {
            Type = "oneshot";
          };
        };

      networking.hosts = {
        "127.0.0.1" = [ "${config.services.nextcloud.hostName}"  "collabora.dyn.iikon.se" ];
        "::1" = [ "${config.services.nextcloud.hostName}" "collabora.dyn.iikon.se" ];
      };
    };
}
