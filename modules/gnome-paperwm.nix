{ config, lib, pkgs, ... }:

let
  cfg = config.simon.gnome-paperwm;
in
{
  options.simon.gnome-paperwm =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to enable the PaperWM tiling window manager (Gnome Shell extension)
          '';
      };
    };

  config = lib.mkIf cfg.enable
    {
      simon.gnome.enable = true;

      environment.systemPackages = [
          pkgs.gnomeExtensions.paperwm
        ];

      home-manager.users.simon = { ... }:
        {
          dconf.settings =
            {
              "org/gnome/shell" = {
                enabled-extensions = [
                  "paperwm@paperwm.github.com"
                ];
              };
            };
        };
    };
}

  # add removed default shortcut <Super>t
  # check other settings to be declared
