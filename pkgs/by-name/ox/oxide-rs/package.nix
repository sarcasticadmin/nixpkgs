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

rustPlatform.buildRustPackage rec {
  pname = "oxide-rs";
  version = "0.9.0+20241204.0.0";

  src = fetchFromGitHub {
    owner = "oxidecomputer";
    repo = "oxide.rs";
    #rev = "v${version}";
    rev = "05596baf0cda85f2d20f29b4c6e94f29df86dcea";
    hash = "sha256-bqTPPWg+Q9jnWj6aVcgTCphz1UWh7V04+Vf3RbFLuA4=";
    #hash = "sha256-NtTXpXDYazcXilQNW455UDkqMCFzFPvTUkbEBQsWIDo=";
    # leaveDotGit is necessary because `build.rs` expects git information which
    # is used to write a `built.rs` file which is read by the CLI application
    # to display version information.
    leaveDotGit = true;
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "oxnet-0.1.0" = "sha256-DZBJKddDSx1xAlDZajOuqwqQl06lh+eNxG0pe2uWEU8=";
      "thouart-0.1.0" = "sha256-GqSHyhDCqQCC8dCvXzsn2WMcNKJxJWXrTcR38Wr3T1s=";
      "progenitor-0.8.0" = "sha256-pgKzPPUheqkE0LM4CUAIOUb9A2GSFnaVGeLInvC80Wg=";
      "typify-0.2.0" = "sha256-Gqa2CwICMC4ZlKytbX3afsBODE1581NXImoGDCf5GoI=";
    };
  };

  cargoBuildFlags = [
    "--package=oxide-cli"
    "--package=xtask"
  ];

  cargoTestFlags = [
    "--package=oxide-cli"
  ];

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

  meta = {
    description = "The Oxide Rust SDK and CLI";
    homepage = "https://github.com/oxidecomputer/oxide.rs";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [
      djacu
      sarcasticadmin
    ];
    mainProgram = "oxide";
  };
}
