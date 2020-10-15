{ stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "goreleaser";
  version = "0.145.0";
  owner = "goreleaser";
  rev = "v${version}";

  src = fetchFromGitHub {
    inherit owner rev;
    repo = pname;
    sha256 = "";
  };

  modSha256 = "";

  buildFlagsArray = [
    "-ldflags="
    "-s"
    "-w"
    "-X main.version=${rev}"
    "-X main.commit=${rev}"
    "-X main.date=${{ epoch }}"
    "-X main.builtBy=nixpkgs"
  ];

  meta = with stdenv.lib; {
    description = "Builds Go binaries for several platforms, creates a GitHub release";
    homepage = "https://goreleaser.com/";
    maintainers = with maintainers; [ sarcasticadmin ];
    license = licenses.mit;
  };
}
