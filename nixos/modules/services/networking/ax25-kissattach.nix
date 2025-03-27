{ config, lib, pkgs, ... }:

let

  inherit (lib)
    types
    ;

  inherit (lib.strings)
    removePrefix
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

      tty = mkOption {
        # maybe this should be types.path
				type = types.str;
				default = "/dev/ttyACM0";
      };

      port = mkOption {
				type = types.str;
				default = "tnc0";
      };

      callsign = mkOption {
				type = types.str;
				example = "WB6WLV";
      };

      description = mkOption {
				type = types.str;
        default = "";
      };

      baud = mkOption {
				type = types.int;
				default = 57600;
      };

      paclen = mkOption {
				type = types.int;
				default = 255;
      };

      window = mkOption {
				type = types.int;
				default = 7;
      };

      kissParams = mkOption {
				type = types.nullOr types.str;
				default = null;
        example = "-t 300 -l 10 -s 12 -r 80 -f n";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.etc."ax25/axports" = {
          text = ''
            ${cfg.port} ${cfg.callsign} ${toString cfg.baud} ${toString cfg.paclen} ${toString cfg.window} ${cfg.description}
          '';
          mode = "0644";
    };

    systemd.services.ax25-attach = {
      description = "AX.25 attach kiss interface";
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "exec";
      serviceConfig.ExecStart = "${cfg.package}/bin/kissattach ${cfg.tty} ${cfg.port}";
      postStart = lib.optionalString (cfg.kissParams != null) "${cfg.package}/bin/kissparms -p ${cfg.port} ${cfg.kissParams}";
    };
  };
}
