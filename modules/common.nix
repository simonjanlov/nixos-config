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

    simon.isStableSystem = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Whether the system should be built on stable releases.
      '';
    };
  };

  config =

    {
      nix.nixPath = [
        "nixos-config=/etc/nixos/machines/${config.networking.hostName}.nix"
        "/nix/var/nix/profiles/per-user/root/channels"

        (lib.mkIf config.simon.isStableSystem
          "nixpkgs=/etc/nixos/modules/nixpkgs-stable"
        )
        (lib.mkIf (!config.simon.isStableSystem)
          "nixpkgs=/etc/nixos/modules/nixpkgs-unstable"
        )
      ];

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

        programs.git = {
          enable = true;
          settings.user.email = "simon.janlov@gmail.com";
          settings.user.name = "simonjanlov";
        };

        programs.delta = {
          enable = true;
          options = {
            navigate = true;
            side-by-side = true;
            true-color = "always";
          };
          enableGitIntegration = true;
        };

        home.file.".config/nixpkgs/config.nix".text = ''
          { allowUnfree = true; }
          '';

        home.stateVersion = config.system.stateVersion;
      };

      environment.systemPackages = with pkgs; [
        wget
        gnupg
        file
        tree
        killall
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
        lm_sensors
      ];

      programs.direnv.enable = true;

      users.users.${config.simon.username} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "flatpak" "networkmanager" "video" "lp" "scanner" ];
        uid = 1000;
        initialPassword = "asdfasdf";
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHbLcS53AasTSnalHAa63cMg+YaVzBUaI1ZYN4oGXaS+UhhjxWl+Sw5wPa3Nfby2kzgPPBqv0zwFh3pgH4tTinikQmmNEQGQKqB1mfEmJhZa3eqe40MhUGGKM8ihj7c0yY51YxIA4+h7tN5Kp/wOUoSmwEvKb81ywGVRhfG/sDdsSe/DaM/q0vi68ckbfLManmdPFXrhXUOuR3t2Q/2ZPirK51EkoTcPo2xASK3CuvK3imfnN7b/RbVKGFoecq7cK/9Vcj1alufepkvmndv2wwMuuIiv1osA6GytKR59oRnDtrqrj5TTl8wLsVoRQ6Mj+JJRiXPkX2jmEZgYaJpCcsBgp/EMjjXhzzs/vVcLzVLe8POzL30jZYwNlyWgMt8yOYjzBj3CFfhzEttj89htjE8gnuAw9g/sl+RM51wDGZ6i55jyIgjJnafy8130iiu4nV9MtoqHzqlafRJc30pTxjRfK/UQuA50ULoLjNh6yGeugm4MW5vQ7ANA4O0cKs/8JIqv6XcmePel23UUxiouAOkkODPBNpOy/dMq2OdRgwOu2acCd2BRDMNFGQnox8sTEvHybCYIoHjp8FCz/4Nt7oAliPtp330bpeT9rmZpLOU4hN5jh/KX7mEj3ZdnpeZfa7BLUoA2wm5CbXs5fnX0LmXDxZ32aqTR8nQbyDBJS0AQ== simon@simon-nixos-2024-09-23"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtWB5DWpkKbMCl/V3/PjUWYwepUtyTLuoseWy0AfSAF simon@MacBookPro"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9iVS8vxiZE2BaIJgGi97mBcwHRkz3VEowpjt5JrEcf simon@michi"
        ];
      };

      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDHbLcS53AasTSnalHAa63cMg+YaVzBUaI1ZYN4oGXaS+UhhjxWl+Sw5wPa3Nfby2kzgPPBqv0zwFh3pgH4tTinikQmmNEQGQKqB1mfEmJhZa3eqe40MhUGGKM8ihj7c0yY51YxIA4+h7tN5Kp/wOUoSmwEvKb81ywGVRhfG/sDdsSe/DaM/q0vi68ckbfLManmdPFXrhXUOuR3t2Q/2ZPirK51EkoTcPo2xASK3CuvK3imfnN7b/RbVKGFoecq7cK/9Vcj1alufepkvmndv2wwMuuIiv1osA6GytKR59oRnDtrqrj5TTl8wLsVoRQ6Mj+JJRiXPkX2jmEZgYaJpCcsBgp/EMjjXhzzs/vVcLzVLe8POzL30jZYwNlyWgMt8yOYjzBj3CFfhzEttj89htjE8gnuAw9g/sl+RM51wDGZ6i55jyIgjJnafy8130iiu4nV9MtoqHzqlafRJc30pTxjRfK/UQuA50ULoLjNh6yGeugm4MW5vQ7ANA4O0cKs/8JIqv6XcmePel23UUxiouAOkkODPBNpOy/dMq2OdRgwOu2acCd2BRDMNFGQnox8sTEvHybCYIoHjp8FCz/4Nt7oAliPtp330bpeT9rmZpLOU4hN5jh/KX7mEj3ZdnpeZfa7BLUoA2wm5CbXs5fnX0LmXDxZ32aqTR8nQbyDBJS0AQ== simon@simon-nixos-2024-09-23"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICtWB5DWpkKbMCl/V3/PjUWYwepUtyTLuoseWy0AfSAF simon@MacBookPro"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO9iVS8vxiZE2BaIJgGi97mBcwHRkz3VEowpjt5JrEcf simon@michi"
      ];
    };
}
