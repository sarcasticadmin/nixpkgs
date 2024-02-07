{ lib, fetchFromGitHub, rustPlatform, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "oxide-rs";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "oxidecomputer";
    repo = "oxide.rs";
    #rev = "b5d5a8ccce98b9366a26fc133574579379dbcc0c";
    rev = "v${version}";
    hash = "sha256-Zkvrc7Poj3Btz2Dz0QP5lrsnHm3KW1/FfmOezbXXQ/8=";
  };

  buildInputs = [
    openssl
  ];

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "progenitor-0.4.0" = "sha256-ONEDxWo/rUeSW6Q48XRfn8j+3akSK9VRBX0fINg0fSI=";
      "thouart-0.1.0" = "sha256-0Ty8Uah3k74zDfw66trqJkmitLkdD0sc30gQ21nZQIU=";
      "typify-0.0.15" = "sha256-peHMk0gdFAUVUr0zlEAwBoAxjpjBKsdbQ7hr+Gx1YHA=";
      "dropshot-0.9.1-dev" = "sha256-1FxC0qeUfiYM/nGf/ioVnpSl4eMAA2+nPxx4OICpB0w=";
      #"progenitor" = "";
      #"thouart" = "";
      #"typify" = "";
    };
  };

  patches = [./oxide-git-version.patch];

  # Needed to get openssl-sys to use pkg-config.
  OPENSSL_NO_VENDOR = 1;
  OPENSSL_LIB_DIR = "${lib.getLib openssl}/lib";
  OPENSSL_DIR = "${lib.getDev openssl}";

  doCheck = false;

  meta = with lib; {
    description = "The Oxide Rust SDK and CLI";
    homepage = "https://github.com/oxidecomputer/oxide.rs";
    license = licenses.unlicense;
    maintainers = [ maintainers.sarcasticadmin ];
  };
}
