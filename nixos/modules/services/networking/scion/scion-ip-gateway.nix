{ config, lib, pkgs, ... }:

with lib;

let
  globalCfg = config.services.scion;
  cfg = config.services.scion.scion-ip-gateway;
  toml = pkgs.formats.toml { };
  connectionDir = if globalCfg.stateless then "/run" else "/var/lib";
  defaultConfig = {
    ASes = { };
    ConfigVersion = 9001;
  };
  configFile = toml.generate "scion-ip-gateway.toml" (recursiveUpdate defaultConfig cfg.settings);
in
{
  options.services.scion.scion-ip-gateway = {
    enable = mkEnableOption "the scion-ip-gateway service";
    settings = mkOption {
      default = { };
      type = toml.type;
      example = literalExpression ''
        "ASes": {
          "2-ffaa:0:b": {
              "Nets": [
                  "172.16.12.0/24"
              ]
          }
    	},
        "ConfigVersion": 9001 
      '';
      description = ''
        scion-ip-gateway configuration. Refer to
        <https://docs.scion.org/en/latest/manuals/common.html>
        for details on supported values.
      '';
    };
  };
  config = mkIf cfg.enable {
    systemd.services.scion-ip-gateway = {
      description = "SCION Control Service";
      after = [ "network-online.target" "scion-dispatcher.service" ];
      wants = [ "network-online.target" "scion-dispatcher.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        Group = if (config.services.scion.scion-dispatcher.enable == true) then "scion" else null;
        ExecStart = "${globalCfg.package}/bin/gc --config ${configFile}";
        DynamicUser = true;
        Restart = "on-failure";
        KillMode = "control-group";
        RemainAfterExit = false;
      };
    };
  };
}
