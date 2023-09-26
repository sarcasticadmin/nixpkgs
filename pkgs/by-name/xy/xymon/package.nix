{ lib
, stdenv
, fetchsvn
, sqlite
, pcre
, zlib
, c-ares
, rrdtool
, openssl
, libtirpc
, lzo
, lz4
, ntirpc
, rpcsvc-proto
, mtr
, fping
, breakpointHook
}:

stdenv.mkDerivation rec {
  pname = "xymon";
  version = "4.4-alpha";

  nativeBuildInputs = [ breakpointHook ];

  buildInputs = [ sqlite pcre zlib c-ares rrdtool openssl libtirpc lzo lz4 fping ];

  XYMONUSER="nobody";
  env.XYMONHOME="$(out)";
  #USEXYMONPING="y";
  #configurePhase = ''
  #  ./configure --server --fping ${fping}/bin/fping
  #'';
  env.NIX_CFLAGS_COMPILE = toString [ "-I${libtirpc.dev}/include/tirpc" ];

  configurePhase = ''
    ./configure --server --fping ${fping}/bin/fping
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp common/{xymongrep,xymondigest,xymon,xymoncmd,xymonlaunch,xymoncfg} $out/bin/
    mkdir -p $out/lib
    cp lib/*.a $out/lib/
    mkdir -p $out/man/{man1,man5,man7,man8}
    cp common/*.1 $out/man/man1/
    cp common/*.5 $out/man/man5/
    cp common/*.7 $out/man/man7/
    cp common/*.8 $out/man/man8/
    runHook postInstall
  '';

  src = fetchsvn {
    url = "svn://svn.code.sf.net/p/xymon/code/branches/4.x-master";
    rev = "8120";
    sha256 = "sha256-3mJgnNaYdov5GiS//O58LupHF1ohXqW0fT67zvniw7s=";
  };

  meta = with lib; {
    description = "";
    homepage = "svn://svn.code.sf.net/p/xymon/code/trunk";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ ];
    mainProgram = "xymon";
    platforms = platforms.all;
  };
}
