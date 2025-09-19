{ config, lib, pkgs, ... }:

let
  cfg = config.simon.netdata;
in
{
  options.simon.netdata =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to enable the netdata monitoring service
          '';
      };
    };

  config = lib.mkIf cfg.enable
    {
      services.netdata = {
        enable = true;
        package = pkgs.netdata.override { withCloudUi = true; };
        config = {
          web = {
            "bind to" = "127.0.0.1";
          };
          db = {
            "dbengine tier 0 retention size" = "512MiB";
            "dbengine tier 0 retention time" = "10d";
          };
        };
      };

      security.acme.acceptTerms = true;
      security.acme.defaults.email = "simon.janlov@gmail.com";

      simon.nginx-base.enable = true;

      services.nginx.virtualHosts =
        {
          # Netdata server
          "netdata.dyn.iikon.se" =
            {
              forceSSL = true;
              enableACME = true;

              extraConfig = ''
                auth_basic "Restricted Area";
                auth_basic_user_file /run/keys/htpasswd-netdata-kumo;
                '';

              locations."/" = {
                proxyPass = "http://127.0.0.1:19999";
              };
            };
        };
      systemd.services.nginx.serviceConfig.SupplementaryGroups = [
        "keys"
      ];
    };
}
