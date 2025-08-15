{ config, lib, pkgs, ... }:

let
  cfg = config.simon.gnome;
  inherit (lib)
    mkMerge
    mkIf;
in
{
  options.simon.gnome =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
        Whether to enable the gnome desktop.
        '';
      };
      custom-keys = lib.mkOption {
        default = true;
        example = false;
        description = ''
        Whether to enable the custom shortcuts.
        '';
      };
    };

  config = mkIf cfg.enable
    {
      environment.systemPackages = with pkgs;
        [
          gparted
          vscode
          firefox-wayland
          foot
          slack
          bitwarden
          gnome-tweaks
          spotify
          gimp
          gnomeExtensions.launch-new-instance
        ];


      # Enable the X11 windowing system.
      services.xserver.enable = true;


      # Enable the GNOME Desktop Environment.
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;

      # # New syntax from 25.11. Disable gnome on kumo server when
      # # implementing this.
      # services.displayManager.gdm.enable = true;
      # services.desktopManager.gnome.enable = true;


      # Configure keymap in X11
      services.xserver.xkb.layout = "se";
      services.xserver.xkb.options = "eurosign:e,ctrl:nocaps";

      home-manager.users.simon = { lib, ... }:
        {
          dconf.settings = mkMerge [
            (mkIf cfg.custom-keys {
              "org/gnome/settings-daemon/plugins/media-keys" = {
                custom-keybindings = [
                  "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
                  "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
                ];
              };

              "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
                name = "emacsclient";
                binding = "<Super>e";
                command = "emacs";
              };

              "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
                name = "terminal";
                binding = "<Super>t";
                command = "foot";
              };
            })

            {
              "org/gnome/shell" = {
                disabled-extensions = [];
                enabled-extensions = [
                  "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
                ];
                favorite-apps = [ "org.gnome.Nautilus.desktop" ];
              };

              "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
                enable-hot-corners = false;
                show-battery-percentage= true;
              };

              "org/gnome/desktop/peripherals/mouse" = {
                accel-profile = "default";
                natural-scroll = false;
                speed = 0.7682170542635659;
              };

              "org/gnome/desktop/peripherals/touchpad" = {
                disable-while-typing = true;
                natural-scroll = false;
                speed = 0.4496124031007751;
                tap-to-click = false;
                two-finger-scrolling-enabled = true;
              };

              "org/gnome/nautilus/preferences" = {
                default-folder-viewer = "list-view";
                migrated-gtk-settings = true;
                search-filter-time-type = "last_modified";
              };

              "org/gnome/desktop/input-sources" = {
                sources = [
                  (lib.hm.gvariant.mkTuple ["xkb" "se"])
                  (lib.hm.gvariant.mkTuple ["xkb" "us"])
                ];
                xkb-options = [
                  "terminate:ctrl_alt_bksp"
                  "lv3:ralt_switch"
                  "ctrl:nocaps"
                ];
              };
            }
          ];
        };
    };
}
