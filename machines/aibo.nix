{ config, lib, pkgs, modulesPath, ... }:

{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/modules/nixpkgs"
    "nixos-config=/etc/nixos/machines/aibo.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  imports =
    [
      # ./hardware-configuration.nix
      (modulesPath + "/installer/scan/not-detected.nix") # why this?
      ../modules
    ];

  simon.gnome.enable = true;

  # simon.gnome.custom-keys = false;

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

  networking.hostName = "aibo";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  services.avahi.enable = true;
  services.avahi.nssmdns4 = true;
  services.avahi.nssmdns6 = true;

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "sv_SE.UTF-8";
  i18n.extraLocaleSettings.LC_MESSAGES = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  # useXkbConfig = true; # use xkb.options in tty.
  };

  nix.settings = {
    cores = 0;
    experimental-features = [ "nix-command" "flakes" ];
    builders-use-substitutes = true;
  };

  nixpkgs.config.allowUnfree = true;


  users.users.simon = {
    isNormalUser = true;
    extraGroups = [ "wheel" "flatpak" "networkmanager" "video" "lp" "scanner" ];
    uid = 1000;
    initialPassword = "asdfasdf";
  };

  # Use the global nixpkgs options as opposed to home-manager specific nixpkgs
  home-manager.useGlobalPkgs = true;

  # Install via users.users.simon.packages instead of nix-env -i
  home-manager.useUserPackages = true;

  # On activation, move conflicting files by adding extension instead of exiting with an error
  home-manager.backupFileExtension = "hm-backup";

  home-manager.users.simon = {

    programs.bash = {
      enable = true;
      sessionVariables.EDITOR = "emacs";
      historyIgnore = [ "ls" "cd" "exit" ];
    };

    home.file.".myconfig".text = ''
      # This is my new custom config file
      export SIMON_MY_VARIABLE="Hello, Home Manager!"
      '';

    home.stateVersion = config.system.stateVersion;
  };


  environment.systemPackages = with pkgs; [
    wget
    gnupg
    file
    tree
    killall
    git
    htop
    fzf
    fd
    curl
    dconf-editor
    sshfs-fuse
    exfat
    pv
    ripgrep
    openssh
    openssl
    pciutils
    usbutils
    screen
    pwgen
    heimdal
    nix-index
    nixpkgs-review
    gocryptfs
    signing-party
    msmtp
    dnsutils
    bat
    unzip
    parted
    jq
    cpufrequtils
    delta
    duf
    ncdu
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.direnv.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;


  }
