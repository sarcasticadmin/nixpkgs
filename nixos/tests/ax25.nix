import ./make-test-python.nix (
{ pkgs, lib, ... }:
let

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
      environment.etc."ax25/axports" = {
        text = ''
          # me callsign speed paclen window description
          #
          tnc0 nocall-${toString nodeId} 57600 255 7 Winlink
        '';

        # The UNIX file mode bits
        mode = "0644";
      };
      services.ax25.kissAttach = {
        enable = true;
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
          ExecStart = "${pkgs.socat}/bin/socat -d -d tcp:192.168.1.1:1234 pty,link=/dev/ttyACM0,b57600,raw";
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
      start_all()
      node1.succeed("lsmod | grep ax25")
      node1.wait_for_unit("network.target")
      node1.succeed("pgrep socat-broker.sh")
      node1.succeed("pgrep socat")
      node2.wait_for_unit("network.target")
      node2.succeed("pgrep socat")
      node3.wait_for_unit("network.target")
      node3.succeed("pgrep socat")
    '';

}
)
