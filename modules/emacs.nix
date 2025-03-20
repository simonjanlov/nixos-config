{ config, lib, pkgs, ... }:

let
  cfg = config.simon.emacs;
in
{
  options.simon.emacs =
    {
      enable = lib.mkOption {
        default = true;
        type = lib.types.bool;
        example = false;
        description = ''
        Whether to enable my Emacs configuration.
        '';
      };
    };

  config = lib.mkIf cfg.enable
    {
      nixpkgs.overlays =
        [
          (import ./emacs-overlay)
        ];

      environment.systemPackages =
        [
          (pkgs.emacsWithPackagesFromUsePackage {
            config = ./dotfiles/emacs-config.org;
            defaultInitFile = true;
            package = pkgs.emacs-git-pgtk;
          })
        ];

      environment.sessionVariables.EDITOR = "emacs";
    };
}
