{
  lib,
  rustPlatform,
  fetchFromGitHub,
  curl,
  pkg-config,
  libgit2,
  openssl,
  zlib,
  stdenv,
  darwin,
}:

rustPlatform.buildRustPackage {
  pname = "oxide-rs";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "sarcasticadmin";
    repo = "oxide.rs";
    rev = "fe189c66bdab4e857176b9d430f7bc35d8bb167a";
    hash = "sha256-qyLvb/86wTycNWnMfBrfAhTvrZ5KoxbPsqY3taqSa6o=";
    leaveDotGit = true;
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "oxnet-0.1.0" = "sha256-RFTNKLR4JrNs09De8K+M35RDk/7Nojyl0B9d14O9tfM=";
      "thouart-0.1.0" = "sha256-GqSHyhDCqQCC8dCvXzsn2WMcNKJxJWXrTcR38Wr3T1s=";
    };
  };

  buildAndTestSubdir = "cli";

  nativeBuildInputs = [
    curl
    pkg-config
  ];

  buildInputs =
    [
      curl
      libgit2
      openssl
      zlib
    ]
    ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  meta = with lib; {
    description = "The Oxide Rust SDK and CLI";
    homepage = "https://github.com/oxidecomputer/oxide.rs";
    license = licenses.mpl20;
    maintainers = with maintainers; [
      djacu
      sarcasticadmin
    ];
    mainProgram = "oxide-rs";
  };
}
