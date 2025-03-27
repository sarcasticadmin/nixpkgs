import ./make-test-python.nix (
{ pkgs, lib, ... }:
let

  baud = 57600;
  createAX25Node = nodeId: {
      boot.kernelPackages = pkgs.linuxPackages_ham;
      boot.kernelModules = [ "ax25" ];
      # TODO
      #DISABLE FIREWALL
      networking.firewall.enable = false;
      environment.systemPackages = with pkgs; [
        libax25
        ax25-tools
        ax25-apps
        socat
      ];
      services.ax25.kissAttach = {
        inherit baud;
        enable = true;
        callsign = "nocall-${toString nodeId}";
        description = "mocked tnc";
      };
      services.ax25.axlisten = {
        enable = true;
      };

      systemd.services.ax25-mock-ether =
      {
        description = "mock radio ether";
        wantedBy = [ "default.target" ];
        requires = [ "network.target" ];
        before = [ "ax25-mock-hardware.service" ];
        # broken needs access to "ss" or "netstat"
        path = [ pkgs.iproute2 ];
        serviceConfig = {
          Type = "exec";
          ExecStart = "${pkgs.socat}/bin/socat-broker.sh tcp4-listen:1234";
        };
        postStart = "${pkgs.coreutils}/bin/sleep 2";
      };
      systemd.services.ax25-mock-hardware =
      {
        description = "mock AX.25 TNC and Radio";
        wantedBy = [ "default.target" ];
        before = [ "ax25-attach.service" "axlisten.service" ];
        #after = [ "network.target" ];
        requires = [ "network.target" "ax25-mock-ether.service" ];
        serviceConfig = {
          Type = "exec";
          ExecStart = "${pkgs.socat}/bin/socat -d -d tcp:192.168.1.1:1234 pty,link=/dev/ttyACM0,b${toString baud},raw";
        };
      };
    };
in
{
  name = "ax25simple";
  nodes = {
    node1 = createAX25Node 1;
    node2 = createAX25Node 2;
    node3 = createAX25Node 3;
  };
  testScript = { nodes, ... }:
    ''
      node1.start()
      node1.succeed("lsmod | grep ax25")
      node1.wait_for_unit("network.target")
      node1.succeed("pgrep socat-broker.sh")
      node1.succeed("pgrep socat")
      node2.start()
      node3.start()
      node2.wait_for_unit("network.target")
      node2.succeed("pgrep socat")
      node3.wait_for_unit("network.target")
      node3.succeed("pgrep socat")
      node1.succeed("echo hello | ax25_call tnc0 nocall-1 nocall-3")
    '';

}
)
