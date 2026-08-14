{ config, lib, ... }:
{
options.simon.msmtp =
  {
    enable = lib.mkOption {
      default = false;
      example = true;
      description = ''
        Whether to use msmpt as a sendmail replacement.
      '';
    };
  };

config = lib.mkIf config.simon.msmtp.enable
  {
    programs.msmtp = {
      enable = true;
      setSendmail = true;
      defaults = {
        aliases = "/etc/aliases";
        port = 587;
        auth = true;
        tls = true;
      };

      accounts.default = {
        host = "smtp.gmail.com";
        passwordeval = "cat ${config.deployment.keys.msmtp-secrets.path}";
        user = "simon.janlov@gmail.com";
        from = "simon.janlov@gmail.com";
      };
    };

    environment.etc.aliases.text = ''
        root: simon.janlov@gmail.com
        default: simon.janlov@gmail.com
      '';
  };
}
