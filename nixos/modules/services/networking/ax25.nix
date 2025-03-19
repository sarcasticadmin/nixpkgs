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

  ax25ToolsPkg = cfg.package;

  kissScript = pkgs.writeScript "kissScript" ''
    #!${pkgs.runtimeShell}
    # This daemons so we should be all set
    ${ax25ToolsPkg}/bin/kissattach ${cfg.tty} ${cfg.port}
    # Post start script instead
    ${ax25ToolsPkg}/bin/kissparms -p ${cfg.port} ${cfg.extraKISSParams}
  '';
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
				default = "wl2k";
      };

      extraKISSParams = mkOption {
				type = types.str;
				default = "-t 300 -l 10 -s 12 -r 80 -f n";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ax25-init = {
      description = "AX.25 init KISS interface";
      after = [ "network.target" ];
      #serviceConfig.Type = "forking";
      serviceConfig.Type = "simple";
      serviceConfig.ExecStart = "${kissScript}";
    };
  };
}
