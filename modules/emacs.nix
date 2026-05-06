{ config, lib, pkgs, ... }:

let
  cfg = config.simon.emacs;

  emacs = pkgs.emacsWithPackagesFromUsePackage {
    config = ./dotfiles/emacs-config-simon.org;
    defaultInitFile = true;
  };

  languageServers = with pkgs; [
    nil
    bash-language-server
    python3Packages.python-lsp-server
  ];

  emacsWithLanguageServers = pkgs.runCommand "emacs-with-language-servers" {
    nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
      makeWrapper ${emacs}/bin/emacs $out/bin/emacs --prefix PATH : ${lib.makeBinPath languageServers }
      ln -s ${emacs}/share $out/share
    '';
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
          emacsWithLanguageServers
        ];

      environment.sessionVariables.EDITOR = "emacs";
    };
}
