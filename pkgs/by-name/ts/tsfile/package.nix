{
  lib,
  fetchFromGitHub,
  maven,
  ...
}: let
  version = "2.0.1";
in maven.buildMavenPackage {
  pname = "tsfile";
  inherit version;

  src = fetchFromGitHub {
    owner = "apache";
    repo = "tsfile";
    tag = "v${version}";
    hash = "sha256-fC63pC3pmRZ1OG43Ugug+zjplD8+HvJ7/futGmjpSoc=";
  };

  mvnHash = lib.fakeHash;

  meta = {
    description = "A columnar storage file format designed for time series data";
    homepage = "https://tsfile.apache.org";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.samw ];
  };
}

