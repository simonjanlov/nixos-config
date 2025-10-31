{ ... }:

{
  imports =
    [
      ./backups.nix
      ./cachix.nix
      ./common.nix
      ./gnome.nix
      ./gnome-paperwm.nix
      ./emacs.nix
      ./nginx-base.nix
      ./netdata.nix
      ./intrusion-prevention.nix
      ./deployment-tools.nix
      ./work.nix
      ./immich.nix
      ./domain.nix
      ./vaultwarden.nix
    ];
}
