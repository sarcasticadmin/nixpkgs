{ config, lib, pkgs, ... }:

let
  inherit (lib)
    types
    ;

  inherit (lib.modules)
    mkIf
    ;

  inherit (lib.options)
    mkEnableOption
    literalExpression
    mkOption
    ;

  cfg = config.services.ax25.axlisten;
in
{
  options = {

    services.ax25.axlisten = {

      enable = mkEnableOption (lib.mdDoc "AX.25 axlisten daemon");

      package = mkOption {
        type = types.package;
        default = pkgs.ax25-apps;
        defaultText = literalExpression "pkgs.ax25-apps";
        description = lib.mdDoc "The ax25-apps package to use.";
      };

      config = mkOption {
				type = types.str;
        description = lib.mdDoc "config flags for axlisten";
				default = "-art";
      };
    };
  };

  config = mkIf cfg.enable {

    systemd.services.axlisten =
      {
        description = "AX.25 traffic monitor";
        after = [ "network.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${cfg.package}/bin/axlisten ${cfg.config}";
        };
      };
  };
}
