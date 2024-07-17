{ stdenv, lib, bundlerEnv, bundlerUpdateScript, makeWrapper, ruby }:

bundlerEnv {
  pname = "terraspace";

  inherit ruby;
  name = "terraspace";
  gemdir  = ./.;

  passthru.updateScript = bundlerUpdateScript "terraspace";

  meta = with lib; {
    description = "Terraform framework that provides an organized structure, and keeps your code DRY";
    mainProgram = "terraspace";
    homepage    = "https://github.com/boltops-tools/terraspace";
    license     = licenses.asl20;
    platforms   = ruby.meta.platforms;
    maintainers = with maintainers; [ mislavzanic ];
  };
}
