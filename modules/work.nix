{ config, lib, pkgs, ... }:

let
  cfg = config.simon.work;
in
{
  options.simon.work =
    {
      enable = lib.mkOption
        {
          default = false;
          example = true;
          description = ''
          Whether to enable work-related settings
          '';
        };
    };

  config = lib.mkIf cfg.enable
    {
      environment.systemPackages = with pkgs; [
        nomachine-client
      ];

      # Enable CUPS to print documents.
      services.printing = {
        enable = true;
        drivers = with pkgs; [
          hplipWithPlugin
        ];
      };

      # Enable SANE to scan documents.
      services.saned.enable = true;
      hardware.sane.enable = true;
      hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];
      hardware.sane.netConf = "printer.internal.xlnaudio.com";
    };
}
