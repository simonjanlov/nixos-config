{ config, lib, pkgs, ... }:
let
  cfg = config.simon.prompt-styling;
in
{
  options.simon.prompt-styling =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to apply custom teminal prompt styling.
        '';
      };
    };

  config = lib.mkIf cfg.enable
    {
      # home-manager.users.${config.simon.username} = {
      #   programs.powerline-go.enable = true;
      #   programs.powerline-go.newline = true;
      # };


      ### POWERLINE-GO HOME MANAGER MANUAL ###

      # environment.systemPackages = [ pkgs.powerline-go ];

      # home-manager.users.${config.simon.username} = {
      #   programs.bash.initExtra = ''
      #     function _update_ps1() {
      #       PS1="$(${pkgs.powerline-go}/bin/powerline-go -error $? -jobs $(jobs -p | wc -l) -newline -cwd-mode "fancy" -git-mode "compact")"

      #       # Uncomment the following line to automatically clear errors after showing
      #       # them once. This not only clears the error for powerline-go, but also for
      #       # everything else you run in that shell. Don't enable this if you're not
      #       # sure this is what you want.

      #       #set "?"
      #     }

      #     if [ "$TERM" != "linux" ]; then
      #       PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
      #     fi
      #   '';
      # };
    };
}
