{ config, lib, pkgs, ... }:

let
  cfg = config.simon.netdata;
  keys = config.deployment.keys;
  unstable = import /etc/nixos/modules/nixpkgs-unstable {
    config = { allowUnfree = true; };
  };
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
        package = unstable.netdata.override { withCloudUi = true; };
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

      simon.nginx-base.enable = true;

      services.nginx.virtualHosts =
        {
          "netdata.dyn.iikon.se" =
            {
              forceSSL = true;
              enableACME = true;

              extraConfig = ''
                auth_basic "Restricted Area";
                auth_basic_user_file ${keys.htpasswd-netdata-kumo.path};
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
