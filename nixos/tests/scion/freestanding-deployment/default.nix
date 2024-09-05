# implements https://github.com/scionproto/scion/blob/27983125bccac6b84d1f96f406853aab0e460405/doc/tutorials/deploy.rst
import ../../make-test-python.nix ({ pkgs, ... }:
let
  trust-root-configuration-keys = pkgs.runCommand "generate-trc-keys.sh" {
    buildInputs = [
      pkgs.scion
    ];
  } (builtins.readFile ./bootstrap.sh);

  imports = hostId: [
    ({
      services.scion = {
        enable = true;
        bypassBootstrapWarning = true;
      };
      networking = {
        useNetworkd = true;
        useDHCP = false;
      };
      systemd.network.networks."01-eth1" = {
        name = "eth1";
        networkConfig.Address = "192.168.1.${toString hostId}/24";
      };
      environment.etc = {
        "scion/topology.json".source = ./topology${toString hostId}.json;
        "scion/crypto/as".source = trust-root-configuration-keys + "/AS${toString hostId}";
        "scion/certs/ISD42-B1-S1.trc".source = trust-root-configuration-keys + "/ISD42-B1-S1.trc";
        "scion/keys/master0.key".text = "U${toString hostId}v4k23ZXjGDwDofg/Eevw==";
        "scion/keys/master1.key".text = "dBMko${toString hostId}qMS8DfrN/zP2OUdA==";
      };
      environment.systemPackages = [
        pkgs.scion
      ];
    })
  ];
in
{
  name = "scion-test";
  nodes = {
    scion01 = { ... }: {
      imports = (imports 1);
    };
    scion02 = { ... }: {
      imports = (imports 2);
    };
    scion03 = { ... }: {
      imports = (imports 3);
    };
    scion04 = { ... }: {
      imports = (imports 4);
    };
    scion05 = { ... }: {
      imports = (imports 5);
    };
  };
  testScript = let
    pingAll = pkgs.writeShellScript "ping-all-scion.sh" ''
      addresses="42-ffaa:1:1 42-ffaa:1:2 42-ffaa:1:3 42-ffaa:1:4 42-ffaa:1:5"
      timeout=100
      wait_for_all() {
        for as in "$@"
        do
          scion showpaths $as --no-probe > /dev/null
          return 1
        done
        return 0
      }
      ping_all() {
        for as in "$@"
        do
          scion ping "$as,127.0.0.1" -c 3
        done
        return 0
      }
      for i in $(seq 0 $timeout); do
        wait_for_all $addresses && exit 0
        ping_all $addresses && exit 0
        sleep 1
      done
    '';
  in
  ''
    # List of AS instances
    machines = [scion01, scion02, scion03, scion04, scion05]

    # Functions to avoid many for loops
    def start(allow_reboot=False):
        for i in machines:
            i.start(allow_reboot=allow_reboot)

    def wait_for_unit(service_name):
        for i in machines:
            i.wait_for_unit(service_name)

    def succeed(command):
        for i in machines:
            i.succeed(command)

    def reboot():
        for i in machines:
            i.reboot()

    def crash():
        for i in machines:
            i.crash()

    # Start all machines, allowing reboot for later
    start(allow_reboot=True)

    # Wait for scion-control.service on all instances
    wait_for_unit("scion-control.service")

    # Execute pingAll command on all instances
    succeed("${pingAll} >&2")

    # Restart all scion services and ping again to test robustness
    succeed("systemctl restart scion-* >&2")
    succeed("${pingAll} >&2")

    # Reboot machines, wait for service, and ping again
    reboot()
    wait_for_unit("scion-control.service")
    succeed("${pingAll} >&2")

    # Crash, start, wait for service, and ping again
    crash()
    start()
    wait_for_unit("scion-control.service")
    succeed("pkill -9 scion-* >&2")
    wait_for_unit("scion-control.service")
    succeed("${pingAll} >&2")
  '';
})
