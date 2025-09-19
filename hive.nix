### Configuration for deployment with colmena ###
{
  meta = {
    nixpkgs = ./modules/nixpkgs-stable;

    nodeNixpkgs = {
      aibo = ./modules/nixpkgs-unstable;
    };
  };

  # Attribute name must match the networking.hostName
  aibo = { ... }: {

    deployment = {
      allowLocalDeployment = true;
      targetHost = null;
    };

    imports = [ ./machines/aibo.nix ];
  };

  kumo = { ... }: {

    deployment = {
      targetHost = "dyn.iikon.se";
      keys = {
        "cloudflare-DNS-token".keyFile = "/etc/nixos/secrets/cloudflare-DNS-token";
        "htpasswd-netdata-kumo".keyFile = "/etc/nixos/secrets/htpasswd-netdata-kumo";
        "htpasswd-netdata-kumo".user = "nginx";
      };
    };

    imports = [ ./machines/kumo.nix ];
  };
}
