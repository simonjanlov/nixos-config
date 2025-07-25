# { config, lib, ... }:
{ ... }:

{
  imports =
    [
      ./cachix.nix
      ./common.nix
      ./gnome.nix
      ./gnome-paperwm.nix
      ./emacs.nix
      # ./home-manager/nixos
    ];
    # (lib.mkIf config.simon.isStableSystem [
    #   ./home-manager-stable/nixos
    # ])
    # (lib.mkIf (!config.simon.isStableSystem) [
    #   ./home-manager/nixos
    # ]);


    # # ++ (if config.simon.isStableSystem then
    # #   [ ./home-manager-stable/nixos ]
    # # else
    # #   [ ./home-manager/nixos ]);
}
