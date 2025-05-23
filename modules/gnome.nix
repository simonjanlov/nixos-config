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
          sticky-notes
          gnomeExtensions.paperwm
        ];


      # Enable the X11 windowing system.
      services.xserver.enable = true;


      # Enable the GNOME Desktop Environment.
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.desktopManager.gnome.enable = true;


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
                  "windowsNavigator@gnome-shell-extensions.gcampax.github.com"
                  "paperwm@paperwm.github.com"
                ];
                favorite-apps = [ "org.gnome.Nautilus.desktop" ];
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
