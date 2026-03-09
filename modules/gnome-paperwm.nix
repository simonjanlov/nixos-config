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

              "org/gnome/shell/extensions/paperwm" = {
                cycle-height-steps = [0.38195000000000001 0.5 0.61804000000000003];
                cycle-width-steps = [0.38195000000000001 0.5 0.61804000000000003];
                disable-topbar-styling = false;
                edge-preview-enable = true;
                edge-preview-scale = 0.14999999999999999;
                horizontal-margin = 8;
                selection-border-radius-bottom = 4;
                selection-border-radius-top = 8;
                selection-border-size = 4;
                show-focus-mode-icon = false;
                show-open-position-icon = false;
                show-window-position-bar = false;
                show-workspace-indicator = false;
                use-default-background = true;
                vertical-margin = 10;
                vertical-margin-bottom = 10;
                window-gap = 9;
              };

              "org/gnome/shell/extensions/paperwm/keybindings" = {
                switch-first=[""];
                take-window=[""];
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
