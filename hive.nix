### Configuration for deployment with colmena ###
{
  meta = {
    nixpkgs = ./modules/nixpkgs-stable;

    nodeNixpkgs = {
      aibo = ./modules/nixpkgs-unstable;
    };
  };

  # Attribute name must match the networking.hostName
  aibo = { name, nodes, ... }: {

    deployment = {
      allowLocalDeployment = true;
      targetHost = null;
    };

    imports = [ ./machines/aibo.nix ];
  };

  kumo = { pkgs, ... }: {

    deployment.targetHost = "dyn.iikon.se";

    imports = [ ./machines/kumo.nix ];
  };
}
