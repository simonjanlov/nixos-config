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
        pkgs.gnomeExtensions.unite
        ];

      home-manager.users.simon = { ... }:
        {
          dconf.settings =
            {
              "org/gnome/shell" = {
                enabled-extensions = [
                  "paperwm@paperwm.github.com"
                  "unite@hardpixel.eu"
                ];
              };

              "org/gnome/shell/extensions/unite" = {
                extend-left-box = false;
                greyscale-tray-icons = false;
                hide-activities-button = "never";
                hide-app-menu-icon = true;
                notifications-position = "right";
                reduce-panel-spacing = true;
                show-appmenu-button = false;
                show-desktop-name = false;
                show-legacy-tray = true;
                use-activities-text = false;
              };
            };
        };
    };
}

  # add removed default shortcut <Super>t
  # check other settings to be declared
