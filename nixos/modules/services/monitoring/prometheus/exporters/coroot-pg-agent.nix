{ config, lib, pkgs, options }:

with lib;

let
  cfg = config.services.prometheus.exporters.coroot-pg-agent;
in
{
  port = 9121;
  serviceOpts = {
    serviceConfig = {
      ExecStart = ''
        ${pkgs.prometheus-coroot-pg-agent-exporter}/bin/coroot-pg-agent \
          -listen ${cfg.listenAddress}:${toString cfg.port} \
          ${concatStringsSep " \\\n  " cfg.extraFlags}
      '';
    };
  };
}
