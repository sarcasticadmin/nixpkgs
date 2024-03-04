{ lib
, buildGoModule
, fetchFromGitHub
}:
let
  version = "0.10.0";

  # Injects a `t.Skip()` into a given test since there's apparently no other way to skip tests here.
  # ref: https://github.com/NixOS/nixpkgs/blob/047bc33866bf7004d0ce9ed0af78dab5ceddaab0/pkgs/by-name/vi/vikunja/package.nix#L96
  skipTest = lineOffset: testCase: file:
    let
      jumpAndAppend = lib.concatStringsSep ";" (lib.replicate (lineOffset - 1) "n" ++ [ "a" ]);
    in
    ''
      sed -i -e '/${testCase}/{
      ${jumpAndAppend} t.Skip();
      }' ${file}
    '';
in

buildGoModule {
  pname = "scion";

  inherit version;

  src = fetchFromGitHub {
    owner = "scionproto";
    repo = "scion";
    #rev = "v${version}";
    rev = "4ef18b4160c5b3be4f48b51aea57164a54a64ce9";
    hash = "sha256-0JRxxXFPN/ikicMeMAPBcq7Lu/mGcWER8kuD1a44cuM=";
  };

  vendorHash = "sha256-4nTp6vOyS7qDn8HmNO0NGCNU7wCb8ww8a15Yv3MPEq8=";

  excludedPackages = [ "acceptance" "demo" "tools" "pkg/private/xtest/graphupdater" ];

  #postConfigure = ''
  #  # This test needs docker, so lets skip it
  #  ${skipTest 1 "TestOpensslCompatible" "scion-pki/trcs/sign_test.go"}
  #'';

  doCheck = true;

  meta = with lib; {
    description = "A future Internet architecture utilizing path-aware networking";
    homepage = "https://scion-architecture.net/";
    platforms = platforms.unix;
    license = licenses.asl20;
    maintainers = with maintainers; [ sarcasticadmin matthewcroughan ];
  };
}
