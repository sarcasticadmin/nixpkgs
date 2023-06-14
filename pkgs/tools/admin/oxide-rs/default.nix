{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "oxide-rs";
  version = "unstable-2023-06-12";

  src = fetchFromGitHub {
    owner = "oxidecomputer";
    repo = "oxide.rs";
    rev = "b5d5a8ccce98b9366a26fc133574579379dbcc0c";
    hash = "";
  };

  cargoHash = "";

  meta = with lib; {
    description = "The Oxide Rust SDK and CLI";
    homepage = "https://github.com/oxidecomputer/oxide.rs";
    license = licenses.unlicense;
    maintainers = [ maintainers.sarcasticadmin ];
  };
}
