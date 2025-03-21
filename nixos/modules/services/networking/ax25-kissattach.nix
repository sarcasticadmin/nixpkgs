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

  cfg = config.services.ax25.kissAttach;

in
{

  options = {
    services.ax25.kissAttach = {
      enable = mkEnableOption (lib.mdDoc "ax25 kiss attach to tnc");

      package = mkOption {
        type = types.package;
        default = pkgs.ax25-tools;
        defaultText = literalExpression "pkgs.ax25-tools";
        description = lib.mdDoc "The ax25-tools package to use.";
      };

      # need to add ax25 config with buad rate, etc.

      tty = mkOption {
				type = types.str;
				default = "/dev/ttyACM0";
      };

      port = mkOption {
				type = types.str;
				default = "tnc0";
      };

      kissParams = mkOption {
				type = types.str;
				default = "";
        example = "-t 300 -l 10 -s 12 -r 80 -f n";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ax25-attach = {
      description = "AX.25 attach kiss interface";
      after = [ "network.target" ];
      #serviceConfig.Type = "forking";
      serviceConfig.Type = "simple";
      serviceConfig.ExecStart = "${cfg.package}/bin/kissattach ${cfg.tty} ${cfg.port}";
      postStart = lib.optionalString (cfg.kissParams != "") "${cfg.package}/bin/kissparms -p ${cfg.port} ${cfg.kissParams}";
    };
  };
}
