{ ... }:

{
  imports =
    [
      ./cachix.nix
      ./common.nix
      ./gnome.nix
      ./gnome-paperwm.nix
      ./emacs.nix
      ./nginx-base.nix
      ./netdata.nix
      ./intrusion-prevention.nix
    ];
}
