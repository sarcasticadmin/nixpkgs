{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    types
    ;

  inherit (lib.modules)
    mkIf
    ;

  inherit (lib.options)
    mkEnableOption
    mkOption
    literalExpression
    ;

  cfg = config.services.ax25.ax25d;
in
{
  options = {

    services.ax25.ax25d = {

      enable = mkEnableOption "AX.25 ax25d";

      package = mkOption {
        type = types.package;
        default = pkgs.ax25-tools;
        defaultText = literalExpression "pkgs.ax25-tools";
        description = "The ax25-tools package to use.";
      };

      configFile = mkOption {
        type = types.path;
        example = "/path/to/ax25d.conf";
        description = ''
          config file that will be passed to ax25d.
        '';
      };

      extraArgs = mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "extraArgs for ax25d.";
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
        {
          assertion = config.services.ax25.axports != { };
          message = ''
            ax25d cannot be used without axports.
            Please define at least one axport with
            <option>config.services.ax25.axports</option>.
          '';
        }
      ];

    systemd.services.ax25d = {
      description = "General purpose AX.25, NET/ROM and Rose daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "ax25-axports.target" ];
      requires = [ "ax25-axports.target" ];
      serviceConfig = {
        Type = "exec";
        ExecStart = "${cfg.package}/bin/ax25d -c ${cfg.configFile}";
      };
    };
  };
}
