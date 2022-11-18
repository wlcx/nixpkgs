{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "coroot_pg_agent";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "coroot";
    repo = "coroot-pg-agent";
    rev = "v${version}";
    sha256 = "CjH1y+YeN9Mb0z1aG35fs97ESyIsQ1KzGKooRwIRCNs=";
  };

  vendorSha256 = "NoY3N+dk9xQnuvK/spZFWtj2wk7eWhE2CQL5/zdk0gk=";

  meta = with lib; {
    description = "Prometheus exporter for Postgres focusing on query performance.";
    inherit (src.meta) homepage;
    license = licenses.asl20;
    maintainers = with maintainers; [ samw ];
    platforms = platforms.unix;
  };
}
