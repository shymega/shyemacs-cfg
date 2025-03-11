{
  pkgs,
  lib,
  inputs,
  ...
} @ args: let
  isOsModule = builtins.hasAttr "osConfig" args;
  osConfig =
    if isOsModule
    then builtins.getAttr "osConfig" args
    else {};
in {
  imports = [
    inputs.twist.homeModules.emacs-twist
  ];

  programs.emacs-twist = {
    enable = true;
    emacsclient.enable = true;
    config = inputs.self.packages.${pkgs.system}.emacsEnv;
    earlyInitFile = inputs.self.packages.${pkgs.system}.emacsEarlyInit;
    createInitFile = true;
    createManifestFile = true;
    icons.enable = true;
    serviceIntegration.enable = true;
  };
}
