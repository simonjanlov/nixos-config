{ config, lib, pkgs, ... }:

{
  options = {
    simon.username = lib.mkOption {
      type = lib.types.str;
      default = "simon";
      description = ''
        The username to use for the main system user.
      '';
    };
  };

  config = {

    nix.settings = {
      cores = 0;
      experimental-features = [ "nix-command" "flakes" ];
      builders-use-substitutes = true;
    };

    time.timeZone = "Europe/Stockholm";

    i18n.defaultLocale = "sv_SE.UTF-8";
    i18n.extraLocaleSettings.LC_MESSAGES = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "sv-latin1";
      # useXkbConfig = true; # use xkb.options in tty.
    };

    nixpkgs.config.allowUnfree = true;

    services.avahi.enable = true;
    services.avahi.nssmdns4 = true;
    services.avahi.nssmdns6 = true;

    # Use the global nixpkgs options as opposed to home-manager specific nixpkgs
    home-manager.useGlobalPkgs = true;

    # Install via users.users.simon.packages instead of nix-env -i
    home-manager.useUserPackages = true;

    # On activation, move conflicting files by adding extension instead of exiting with an error
    home-manager.backupFileExtension = "hm-backup";

    home-manager.users.${config.simon.username} = {

      programs.bash = {
        enable = true;
        sessionVariables.EDITOR = "emacs";
        historyIgnore = [ "ls" "cd" "exit" ];
      };

      home.file.".myconfig".text = ''
      # This is a hej custom config file
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

    programs.direnv.enable = true;

    users.users.${config.simon.username} = {
      isNormalUser = true;
      extraGroups = [ "wheel" "flatpak" "networkmanager" "video" "lp" "scanner" ];
      uid = 1000;
      initialPassword = "asdfasdf";
    };



  };
}
