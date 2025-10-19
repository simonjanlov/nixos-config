{ config, lib, pkgs, ... }:

let
  cfg = config.simon.nginx-base;
in
{
  options.simon.nginx-base =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Nginx basic config to be enabled by other nginx-dependent modules
          '';
      };
    };

  config = lib.mkIf cfg.enable
    {
      services.nginx = {
        enable = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;

        appendConfig = ''
          error_log stderr warn;
          '';
        appendHttpConfig = ''
          access_log syslog:server=unix:/dev/log combined;
          '';

        virtualHosts =
          {
            # "Catch all" Default server
            "_" = {
              default = true;
              extraConfig = "return 444;";
            };
          };
      };

      security.acme.acceptTerms = true;
      security.acme.defaults.email = "simon.janlov@gmail.com";
    };
}
