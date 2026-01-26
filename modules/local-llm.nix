{ config, lib, pkgs, ... }:
let
  cfg = config.simon.llm;
  inherit (lib)
    mkOption
    mkMerge
    mkIf;
in
{
  options.simon.llm =
    {
      ollama.enable = mkOption {
        default = false;
        example = true;
        description = ''
          Whether to host local LLM using ollama
          '';
      };
      openWebUI.enable = mkOption {
        default = false;
        example = true;
        description = ''
          Whether to enable the LLM with a Web UI
          '';
      };
    };

  config = mkMerge [

    (mkIf cfg.ollama.enable {
      services.ollama = {
        enable = true;
        loadModels = [
          "llama3.2:3b"
          "gemma3:4b"
          "translategemma:4b"
          "jobautomation/OpenEuroLLM-Swedish:latest"
        ];
        syncModels = true;
        # acceleration = "vulkan";
      };
    })

    (mkIf cfg.openWebUI.enable {
      simon.llm.ollama.enable = true;

      services.open-webui.enable = true;

      simon.nginx-base.enable = true;

      services.nginx.virtualHosts =
        {
          "llm.${config.simon.domain.homelab.domain}" =
            {
              forceSSL = true;
              enableACME = true;

              locations."/" = {
                proxyPass = "http://${config.services.open-webui.host}:${toString config.services.open-webui.port}";
                proxyWebsockets = true;
                extraConfig = ''
                  client_max_body_size 20M;
                '';
              };
            };
        };
    })
  ];
}
