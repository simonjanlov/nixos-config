{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      ../modules
      ../modules/home-manager/nixos
    ];

  simon.isStableSystem = false;
  simon.deployment-tools.enable = true;

  simon.gnome-paperwm.enable = true;

  simon.backups.paths = [ "/home/simon/restic-test" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    # jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  services.pulseaudio.enable = false;

  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;


  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      hplipWithPlugin
    ];
  };

  # Enable SANE to scan documents.
  services.saned.enable = true;
  hardware.sane.enable = true;
  hardware.sane.extraBackends = [ pkgs.hplipWithPlugin ];
  hardware.sane.netConf = "printer.internal.xlnaudio.com";

  # Network related.
  networking.hostName = "aibo";
  networking.networkmanager.dns = "systemd-resolved";
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];
  services.resolved.enable = true;
  services.resolved.fallbackDns = [ ];
  services.resolved.llmnr = "false";


  system.copySystemConfiguration = true;
  system.stateVersion = "24.11";


  ### HARDWARE CONFIGURATION ###

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/0713e632-7b7d-4c7e-b0b9-3871c0033b0d";

  services.xserver.videoDrivers = [
    "modesetting"
  ];

  fileSystems."/" =
    { device = "/dev/root_vg/root";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/B831-0FC2";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/root_vg/swap"; }
    ];


  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

}
