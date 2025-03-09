{
  inputs,
  pkgs,
}: let
  inherit (pkgs) lib;
  inherit (inputs) self;
  org-babel-lib = inputs.org-babel.lib;
  emacsPackage = inputs.nixpkgs.legacyPackages.${pkgs.system}.emacs-pgtk;
in (inputs.twist.lib.makeEnv {
  inherit emacsPackage pkgs;

  nativeCompileAheadDefault = true;
  initParser = inputs.twist.lib.parseUsePackages {
    inherit (inputs.nixpkgs) lib;
  } {};
  lockDir = ./.lock;
  initFiles = [./init.el];

  exportManifest = true;

  configurationRevision = with builtins; "${substring 0 8 self.lastModifiedDate}.${
    if self ? rev
    then substring 0 7 self.rev
    else "dirty.${substring 0 7 (hashFile "sha256" ./init.el)}"
  }";

  registries = import ./registries.nix {
    inherit inputs;
    emacsSrc = emacsPackage.src;
  };
})
