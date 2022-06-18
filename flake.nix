{
  description = " Connects Cloudlog to rigctld / hamlib via PHP";
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.cloudlog-rigctl-interface = let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in pkgs.stdenv.mkDerivation rec {
      name = "cloudlog-rigctl-interface";
      version = "master";
      src = ./.;
      installPhase = ''
        mkdir $out
        cp -R ./* $out
      '';
    };
    checks.x86_64-linux.cloudlog-rigctl-interface = let
      test = import (nixpkgs + "/nixos/lib/testing-python.nix") {
        system = "x86_64-linux";
      };
    in test.simpleTest {
      name = "cloudlog-rigctl-interface";
      nodes.machine = { ... }: {
        imports = [ self.nixosModules.default ];
        nixpkgs.overlays = [ self.overlays.default ];
        services = {
          cloudlog-rigctl-interface = {
            enable = true;
            cloudlog = {
              url = "http://localhost/cloudlog";
              key = "/tmp/cloudlog";
            };
          };
        };
      };
      testScript = ''
        machine.wait_for_unit('cloudlog-rigctl-interface.service')
      '';
    };
    hydraJobs = { inherit (self) packages checks; };
    overlays.default = (final: prev: {
      cloudlog-rigctl-interface = self.packages.x86_64-linux.cloudlog-rigctl-interface;
    });
    nixosModules.default = { pkgs, config, lib, ... }: let
      cfg = config.services.cloudlog-rigctl-interface;
    in {
      options = with lib.types; {
        services.cloudlog-rigctl-interface = {
          enable = lib.mkEnableOption "cloudlog-rigctl-interface";
          rigctl = {
            host = lib.mkOption {
              type = str;
              default = "127.0.0.1";
              description = "rigctl hostname";
            };
            port = lib.mkOption {
              type = int;
              default = 4532;
              description = "rigctl port";
            };
          };
          cloudlog = {
            url = lib.mkOption {
              type = str;
              default = "http://127.0.0.1";
              description = "Cloudlog base URL";
            };
            key = lib.mkOption {
              type = str;
              description = "Path to file containing Cloudlog API key";
            };
          };
          name = lib.mkOption {
            type = str;
            default = "radio";
          };
        };
      };
      config = lib.mkIf cfg.enable {
        systemd.services.cloudlog-rigctl-interface = {
          description = "cloudlog-rigctl-interface";
          enable = true;
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.php}/bin/php ${pkgs.cloudlog-rigctl-interface}/rigctlCloudlogInterface.php";
          };
          environment = {
            RIGCTL_HOST = cfg.rigctl.host;
            RIGCTL_PORT = toString cfg.rigctl.port;
            CLOUDLOG_URL = cfg.cloudlog.url;
            CLOUDLOG_KEY = cfg.cloudlog.key;
            RADIO_NAME = cfg.name;
          };
        };
      };
    };
  };
}
