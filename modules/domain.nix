{ config, lib, ... }:

{
  options.simon.domain =
    {
      homelab.domain = lib.mkOption {
        default = "dyn.iikon.se";
        type = lib.types.str;
        description = ''
        Domain to use for publicly hosted services
        '';
      };
    };
}
