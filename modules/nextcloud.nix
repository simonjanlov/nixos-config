{ config, lib, pkgs, ... }:
let
  cfg = config.simon.nextcloud;
  keys = config.deployment.keys;
in
{
  options.simon.nextcloud =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to host Nextcloud on this machine.
        '';
      };
    };

  config = lib.mkIf cfg.enable
    {
      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud33;
        hostName = "nextcloud.${config.simon.domain.homelab.domain}";
        database.createLocally = true;
        https = true;
        datadir = "/srv/nextcloud";
        config = {
          dbtype = "pgsql";
          adminuser = "admin";
          adminpassFile = "${keys.nextcloud-admin-pw.path}";
        };
        settings = {
          maintenance_window_start = 1;
          default_phone_region = "SE";
          mail_smtphost = "smtp.gmail.com";
          mail_smtpport = 465;
          mail_smtpsecure = "ssl";
          mail_smtpauth = true;
          mail_smtpname = "simon.janlov@gmail.com";
          enabledPreviewProviders = [
            "OC\\Preview\\PNG"
            "OC\\Preview\\JPEG"
            "OC\\Preview\\GIF"
            "OC\\Preview\\BMP"
            "OC\\Preview\\MP3"
            "OC\\Preview\\XBitmap"
            "OC\\Preview\\Krita"
            "OC\\Preview\\WebP"
            "OC\\Preview\\MarkDown"
            "OC\\Preview\\TXT"
            "OC\\Preview\\OpenDocument"
            "OC\\Preview\\HEIC"
          ];
          "overwrite.cli.url" = "https://${config.services.nextcloud.hostName}"; # default value "http://localhost"
        };

        secretFile = "${keys.nextcloud-secrets.path}";
        maxUploadSize = "10G";
        extraApps = with config.services.nextcloud.package.packages.apps; {
          inherit contacts notes tasks music;
        };
        phpOptions = {
          "opcache.interned_strings_buffer" = "64";
          "opcache.memory_consumption" = "256";
          "opcache.jit" = "1255";
          "opcache.jit_buffer_size" = "8M";
          "opcache.validate_timestamps" = "0";
        };
      };

      simon.backups.paths = [
        "${config.services.nextcloud.datadir}"
        "${config.services.nextcloud.home}"
      ];

      systemd.services = lib.genAttrs [
        "nextcloud-setup"
        "nextcloud-update-db"
        "phpfpm-nextcloud"
      ]
        (name: {
          after = [ "nextcloud-admin-pw-key.service" "nextcloud-secrets-key.service" ];
          wants = [ "nextcloud-admin-pw-key.service" "nextcloud-secrets-key.service" ];
        });

      simon.nginx-base.enable = true;

      services.nginx.virtualHosts.${config.services.nextcloud.hostName} =
        {
          forceSSL = true;
          enableACME = true;
        };
    };
}

# Reasonable to add something like this but without the agenix
# dependency?  After updating config parameters, I get served a blank
# screen and phpfpm-nextcloud.service needed to be restarted manually.
#
# # Due to PHP's realpath cache, every time the activation scripts run,
# # Nextcloud stops working for a brief moment.
# # This happens because the secrets handled by agenix change their path,
# # and PHP does not follow the new destination of the symlink until the cache expires.
# # Additionally, we are now disabling OPCache's invalidation, given that files do not change
# # without a NixOS activation.
# # This reloads php-fpm after agenix has updated secrets, so that it clears the cache.
# system.activationScripts.nextcloud-reload = {
#   text = ''
#     if [ "$NIXOS_ACTION" == "switch" ]; then
#       echo phpfpm-nextcloud.service > /run/nixos/activation-reload-list
#     fi
#   '';
#   deps = [ "agenix" ];
# };
