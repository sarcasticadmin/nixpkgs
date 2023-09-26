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
, ntirpc
, fping
, breakpointHook
}:

stdenv.mkDerivation rec {
  pname = "xymon";
  version = "4.4-alpha";

  nativeBuildInputs = [ breakpointHook ];

  buildInputs = [ sqlite pcre zlib c-ares rrdtool openssl libtirpc ntirpc fping ];

  XYMONUSER="nobody";
  #USEXYMONPING="y";
  #configurePhase = ''
  #  ./configure --server --fping ${fping}/bin/fping
  #'';
  configurePhase = ''
    ./configure --server
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
