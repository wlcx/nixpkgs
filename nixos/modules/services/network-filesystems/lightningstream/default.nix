{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.lightningstream;
  settingFmt = pkgs.formats.yaml { };
in
{
  options.services.lightningstream = {
    enable = lib.mkEnableOption "lightningstream";

    package = lib.mkPackageOption pkgs "lightningstream" { };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingFmt.type;
        options = {
          instance = lib.mkOption {
            type = lib.types.str;
            description = "Unique name for this instance. All instances MUST have a unique value.";
          };
          storage = lib.mkOption {
            # N.B. The two keys below "storage" in lightningstream's config are "type" and "options", which are unfortunately both attr names used in nixos's lib.mkOption. So this may look a bit confusing!
            visible = "transparent";
            type = lib.types.submodule {
              freeformType = settingFmt.type;
              options = {
                type = lib.mkOption {
                  type = lib.types.enum [
                    "s3"
                    "azure"
                    "fs"
                    "memory"
                  ];
                  description = "Type of storage backend";
                };
                options = lib.mkOption {
                  type = lib.types.submodule {
                    freeformType = settingFmt.type;
                    options = { };
                  };
                  description = "Options for the storage backend. See the [documentation](https://doc.powerdns.com/lightningstream/latest/configuration/index.html#storage) for each backend";
                };
              };
            };
          };
          lmdbs = lib.mkOption {
            type = lib.types.attrsOf (
              lib.types.submodule {
                freeformType = settingFmt.type;
                options = {
                  path = lib.mkOption {
                    type = lib.types.path;
                    description = "Path to the LMDB directory, or file if `no_subdir` is enabled.";
                  };
                  options = lib.mkOption {
                    type = lib.types.submodule {
                      freeformType = settingFmt.type;
                      options = {
                        create = lib.mkOption {
                          type = lib.types.bool;
                          description = "Create the LMDB if it does not exist yet";
                          default = false;
                        };
                        no_subdir = lib.mkOption {
                          type = lib.types.bool;
                          description = "If `false`, the path to the DB should be to a directory. If `true`, it should be to a file.";
                          default = false;
                        };
                      };
                    };
                  };
                };
              }
            );
            description = ''
              Attrset where each name/value is an LMDB database to sync. The name for each DB must not change over time - it's used in snapshot filenames.
            '';
          };
          http = lib.mkOption {
            visible = "transparent";
            type = lib.types.submodule {
              freeformType = settingFmt.type;
              options.address = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                description = ''
                  Address for the built-in HTTP server with status/prometheus metrics to listen on. Disabled if null.


                '';
                example = ":7000";
                default = null;
              };
            };
          };
        };
      };
      description = ''
        Configuration for lightningstream. See [docs](https://doc.powerdns.com/lightningstream/latest/configuration/index.html) for all options.

        Environment variables can be used - see the description for `environmentFile`
      '';
      default = { };
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/run/secrets/lightningstream";
      description = ''
        Environment file as defined in {manpage}`systemd.exec(5)`.

        Secrets may be passed to the service without adding them to the
        world-readable Nix store, by specifying placeholder variables as
        the option value in Nix and setting these variables accordingly in the
        environment file.

        Lightningstream will replace values of the form `''${ENV_VAR_NAME}` in
        any setting value. This uses the same syntax as Nix string interpolation,
         so make sure to escape correctly. For example (note the `\$`):

        ```nix
        settings.storage.options.secret_key = "\''${LIGHTNINGSTREAM_S3_SECRET}";
        ```
      '';
    };
  };
  config = lib.mkIf cfg.enable {
    systemd.services.lightningstream = {
      description = "Lightning Stream";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
        ExecStart = "${cfg.package}/bin/lightningstream sync -c ${settingFmt.generate "lightningstream.yml" cfg.settings}";
        Restart = "always";
        User = "lightningstream";
        Group = "lightningstream";
      };
    };

    users.users.lightningstream = {
      description = "Lightning Stream user";
      group = "lightningstream";
      isSystemUser = true;
    };
    users.groups.lightningstream = { };
  };
}
