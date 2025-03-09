{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    systems.url = "github:nix-systems/default";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
    twist.url = "github:emacs-twist/twist.nix";
    org-babel.url = "github:emacs-twist/org-babel";
    emacs = {
      url = "github:emacs-mirror/emacs";
      flake = false;
    };
    melpa = {
      url = "github:melpa/melpa";
      flake = false;
    };
    gnu-elpa = {
      url = "github:elpa-mirrors/elpa";
      flake = false;
    };
    nongnu-elpa = {
      url = "github:elpa-mirrors/nongnu";
      flake = false;
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.ez-configs.flakeModule
      ];
      systems = import inputs.systems ++ ["riscv64-linux" "i686-linux"];

      perSystem = {
        config,
        pkgs,
        lib,
        system,
        self,
        emacsEnv,
        ...
      }: 
      {
        _module.args = let
          overlays = [
            inputs.emacs-overlay.overlays.emacs
          ];
        in {
          pkgs = import nixpkgs {inherit system overlays;};
          emacsPackage = nixpkgs.legacyPackages.${system}.emacs-pgtk;
          emacsEnv = import ./conf/emacs {inherit inputs pkgs;};

          config.extraSpecialArgs = {inherit emacsEnv;};
        };

        packages = {
          inherit emacsEnv;
          run-emacs-on-tmpdir =
            pkgs.callPackage
            ./conf/emacs/emacs-on-tmpdir.nix
            {}
            "run-emacs-on-tmpdir"
            emacsEnv;
        };

        checks = {
          # Check if the elisp packages are successfully built.
          build-env =
            emacsEnv.overrideScope (_: _: {executablePackages = [];});
        };
        apps = emacsEnv.makeApps {
          lockDirName = "conf/emacs/.lock";
        };
      };
      ezConfigs = {
        globalArgs = {
          inherit inputs;
          inherit (inputs) self;
        };
        earlyModuleArgs = {
          inherit inputs;
          inherit (inputs) self;
        };
        home = {
          modulesDirectory = ./homeModules;
        };
      };
    };
}
