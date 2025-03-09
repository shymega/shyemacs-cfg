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
    else null;
in {
  imports = [
    inputs.twist.homeModules.emacs-twist
  ];

  programs.emacs-twist = {
    enable = true;
    emacsclient.enable = true;
    config = inputs.self.packages.${pkgs.system}.emacsEnv;
    createInitFile = true;
    createManifestFile = true;
    icons.enable = false;
  };
}
