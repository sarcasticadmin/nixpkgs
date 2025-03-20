import ./make-test-python.nix (
{ pkgs, lib, ... }:
let
  createAX25Node = nodeId: {
      boot.kernelPackages = pkgs.linuxPackages_ham;
      # TODO
      #DISABLE FIREWALL
      networking.firewall.enable = false;
      environment.systemPackages = with pkgs; [
        libax25
        ax25-tools
        ax25-apps
        socat
        tncattach
      ];
      #systemd.services.systemd-networkd.environment.SYSTEMD_LOG_LEVEL = "debug";
      environment.etc."ax25/axports" = {
        text = ''
          # me callsign speed paclen window description
          #
          wl2k nocall-${toString nodeId} 57600 255 7 Winlink
        '';

        # The UNIX file mode bits
        mode = "0644";
      };
      services.ax25-init = {
        enable = true;
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
      node1.execute("socat-broker.sh tcp4-listen:1234 >&2 &")
      node1.succeed("pgrep socat-broker.sh")
      node1.execute("socat -d -d tcp:127.0.0.1:1234 pty,link=/dev/ninotnc,b57600,raw >&2 &")
      node1.succeed("pgrep socat")
      node1.succeed("systemctl restart ax25d.service")
      node2.wait_for_unit("network.target")
      node2.execute("socat -d -d pty,link=/dev/ninotnc,b57600,raw tcp:192.168.1.1:1234 >&2 &")
      node2.succeed("pgrep socat")
      node2.succeed("systemctl restart ax25d.service")
      node3.wait_for_unit("network.target")
      node3.execute("socat -d -d pty,link=/dev/ninotnc,b57600,raw tcp:192.168.1.1:1234 >&2 &")
      node3.succeed("pgrep socat")
      node3.succeed("systemctl restart ax25d.service")
    '';

}
)
