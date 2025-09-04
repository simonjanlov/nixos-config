{ config, lib, pkgs, ... }:

let
  cfg = config.simon.intrusion-prevention;
  openPorts = config.networking.firewall.allowedTCPPorts;
  publicNginx =
    config.services.nginx.enable
    && (builtins.any (TCPPort: builtins.elem TCPPort openPorts) [ 80 443 ]);
in
{
  options.simon.intrusion-prevention =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to enable IP banning with fail2ban
          '';
      };
    };
  config = lib.mkIf cfg.enable
    {
      services.fail2ban = {
        enable = true;
        ignoreIP = [ "192.168.0.0/16" ];
        bantime = "24h";

        jails = lib.mkMerge [
          (lib.mkIf publicNginx
            {
              nginx-propfind.settings = {
                enabled = true;
                port = "http,https";
                findtime = 3600;
              };
              nginx-4xx.settings = {
                enabled = true;
                port = "http,https";
                findtime = 15;
                maxretry = 6;
              };
              nginx-http-auth.settings.enabled = true;
              nginx-botsearch.settings.enabled = true;
              nginx-forbidden.settings.enabled = true;
            })

          {sshd.settings.mode = "aggressive";}
        ];
      };

      # Defining custom jails for fail2ban
      environment.etc = lib.mkIf publicNginx
        {
          "fail2ban/filter.d/nginx-propfind.conf".text = ''
          [Definition]

          failregex = ^.*nginx: <HOST>.*"PROPFIND.*" 401 .*$

          ignoreregex =

          datepattern = {^LN-BEG}

          journalmatch = _SYSTEMD_UNIT=nginx.service + _COMM=nginx
          '';

          "fail2ban/filter.d/nginx-4xx.conf".text = ''
          [Definition]

          failregex = ^.*nginx: <HOST>.*".*" (401|400|403|404|444) .*$

          ignoreregex =

          datepattern = {^LN-BEG}

          journalmatch = _SYSTEMD_UNIT=nginx.service + _COMM=nginx
          '';
        };
    };
}
