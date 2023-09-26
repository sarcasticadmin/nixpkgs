{ lib
, stdenv
, fetchsvn
, sqlite
, pcre
, zlib
, c-ares
, rrdtool
, openssl
}:

stdenv.mkDerivation rec {
  pname = "xymon";
  version = "4.4-alpha";

  buildInputs = [ sqlite pcre zlib c-ares rrdtool openssl ];
  configurePhase = ''
    ./configure --server
  '';

  src = fetchsvn {
    url = "svn://svn.code.sf.net/p/xymon/code/trunk";
    rev = "8120";
    sha256 = "sha256-kRY3qtPZhsibSK+cDb6Mmrvhk66wIZDKf+TrhVV1nas=";
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
