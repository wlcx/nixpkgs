{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  versionCheckHook,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "lightningstream";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "PowerDNS";
    repo = "lightningstream";
    tag = "v${finalAttrs.version}";
    hash = "sha256-r6pOHt5KGzILZLparLq2u7AOvIYASaScmNcOSI7kEVY=";
  };
  # Disable reading version from go's debug/buildinfo (since it's not available without .git), which allows us to set the version via linker flags as god intended.
  patches = [
    ./version.patch
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/PowerDNS/lightningstream/cmd/lightningstream/commands.mainVersion=${finalAttrs.version}"
  ];

  vendorHash = "sha256-19WrmUuUxkhvH8gLtGAghMUX9cjUpY4Go4KPGKwJjB0=";

  nativeBuildInputs = [ installShellFiles ];

  # Install shell completions so long as we can run the binary to do so. This means that
  # when cross compiling we may not be able to generate shell completions.
  # See https://github.com/NixOS/nixpkgs/issues/308283
  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion \
      --cmd lightningstream \
      --bash <($out/bin/lightningstream completion bash) \
      --fish <($out/bin/lightningstream completion fish) \
      --zsh <($out/bin/lightningstream completion zsh)
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "version";
  doInstallCheck = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "LMDB sync via S3 buckets";
    mainProgram = "lightningstream";
    license = lib.licenses.mit;
    homepage = "https://doc.powerdns.com/lightningstream/latest/index.html";
    maintainers = with lib.maintainers; [ samw ];
  };
})
