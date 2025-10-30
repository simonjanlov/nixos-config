{ config, lib, ... }:

{
  options.simon.domain =
    {
      external.domain = lib.mkOption {
        default = "dyn.iikon.se";
        type = lib.types.str;
        description = ''
        Domain to use for publicly hosted services
        '';
      };
    };
}
