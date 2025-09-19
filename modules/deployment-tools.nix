{ config, lib, pkgs, ... }:

let
  cfg = config.simon.deployment-tools;
in
{
  options.simon.deployment-tools =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
        Whether to install tools relevant for the server deployment host
        '';
      };
    };

  config = lib.mkIf cfg.enable
    {
      environment.systemPackages = with pkgs; [
        colmena
        gocryptfs
      ];
    };
}
