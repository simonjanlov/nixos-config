{ config, lib, pkgs, modulesPath, ... }:

{

  nix.nixPath = [
    "nixpkgs=/etc/nixos/modules/nixpkgs-stable"
    "nixos-config=/etc/nixos/machines/kumo.nix"
    "/nix/var/nix/profiles/per-user/root/channels" # is this needed?
  ];

  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      ../modules
    ];

  simon.gnome.enable = true;


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.swraid.enable = true;

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

  networking.hostName = "kumo";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  # services.openssh.settings.PasswordAuthentication = false;

  services.openssh = {
    enable = true;
    settings = {
     KbdInteractiveAuthentication = false;
     PasswordAuthentication = false;
     PermitRootLogin = "prohibit-password";
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  system.stateVersion = "24.11";


  ### Hardware-configuration ###

  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/082e9a9b-bac9-434f-9795-c456dd1935c5";

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "uas" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "r8169" ];

  boot.kernelParams = [ "ip=dhcp" ];
  boot.initrd.network = {
    enable = true;
    ssh.enable = true;
    ssh.hostKeys = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key"
    ];
  };

  networking.useDHCP = false;
  networking.networkmanager.enable = false;

  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/2ec4d25e-d197-4e0e-9428-acbc3ca6b3bb";
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/2818-18CF";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/2ec4d25e-d197-4e0e-9428-acbc3ca6b3bb";
      fsType = "btrfs";
      neededForBoot = true;
      options = [ "subvol=home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/2ec4d25e-d197-4e0e-9428-acbc3ca6b3bb";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/a1d80591-e690-4bec-a573-0c3712dfad11"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

}
