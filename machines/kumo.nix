{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      ../modules
      ../modules/home-manager-stable/nixos
    ];

  simon.isStableSystem = true;

  simon.gnome.enable = true;
  simon.netdata.enable = true;
  simon.intrusion-prevention.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  services.pulseaudio.enable = false;


  ### NETWORK SETUP ###

  networking.hostName = "kumo";
  networking.useDHCP = false;

  systemd.network.enable = true;
  systemd.network.networks."wired" = {
    enable = true;
    matchConfig.Name = "enp8s0";
    DHCP = "no";
    address = [ "192.168.1.3/24" ];
    gateway = [ "192.168.1.1" ];
  };

  services.resolved.enable = true;
  services.resolved.extraConfig = ''
    DNS=192.168.1.1
  '';

  networking.networkmanager.enable = false;

  networking.firewall = {
    enable = true;
    allowPing = true;
    allowedTCPPorts = [ 80 443 19999 ];
  };

  services.ddclient = {
    enable = true;
    protocol = "cloudflare";
    usev4 = "webv4, webv4=dynamicdns.park-your-domain.com/getip";
    usev6 = "no";
    zone = "iikon.se";
    domains = [ "dyn.iikon.se" ];
    username = "token";
    passwordFile = "/etc/secrets/ddclient-token";
  };


  # SSH configuration.
  services.openssh = {
    enable = true;
    settings = {
     KbdInteractiveAuthentication = false;
     PasswordAuthentication = false;
     PermitRootLogin = "prohibit-password";
    };
  };

  # Disable systemd's power-saving targets.
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };


  system.copySystemConfiguration = true;
  system.stateVersion = "24.11";


  ### HARDWARE CONFIGURATION ###

  boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/082e9a9b-bac9-434f-9795-c456dd1935c5";

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "uas" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "r8169" ];

  boot.kernelParams = [ "ip=192.168.1.3::192.168.1.1:255.255.255.0:kumo::none" ];
  boot.initrd.network = {
    enable = true;
    ssh.enable = true;
    ssh.hostKeys = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_rsa_key"
    ];
  };

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


  # APP-DATA RAID #

  boot.swraid.enable = true;

  fileSystems."/srv" = {
    depends = [ "/" ]; # remove?
    device = "/dev/mapper/raid";
    fsType = "btrfs";
    options = [ "subvol=subvol_root" ];
    encrypted = {
      enable = true;
      blkDev = "/dev/disk/by-id/md-uuid-b610a794:6e81ba96:17d5401b:751b1691";
      keyFile = "/mnt-root/etc/secrets/raid-keyfile";
      label = "raid";
    };
  };


  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;

}
