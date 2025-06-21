{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    inputs:
    inputs.flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        inherit (pkgs) lib;

        # common Rust environment for motion-handler
        common = {
          packages = with pkgs; [
            espup
            rustup
            cargo-espflash
            espflash
            ldproxy
          ];

          env = {
            RUSTUP_TOOLCHAIN = "esp";
            CARGO_BUILD_TARGET = "xtensa-esp32s3-none-elf";
          };

          shellHook = ''
            export_file="./motion-handler/export-esp.sh"
            if [[ -f "$export_file" ]]; then
              echo 1>&2 "Updating Rust toolchain for ESP32-S3..."
              espup update
            else
              echo 1>&2 "Setting up Rust toolchain for ESP32-S3..."
              espup install --targets esp32s3 --export-file "$export_file"
            fi

            source "$export_file"
          '';
        };

        fhs-build = pkgs.buildFHSEnv {
          name = "buildroot-env";
          targetPkgs =
            pkgs:
            (
              with pkgs;
              [
                (lib.hiPrio gcc)
                binutils
                cpio
                elfutils.dev
                file
                gnumake
                ncurses.dev
                pkg-config
                unzip
                wget
                which
                pkgsCross.aarch64-multiplatform.gccStdenv.cc

                # crosstool-NG
                autoconf
                automake
                libtool
                gperf
                bison
                flex
                texinfo
                help2man

                # esp-hosted
                cmake
                python3
                udev
                libusb1
                libz
              ]
              ++ common.packages
              ++ pkgs.linux.nativeBuildInputs
            );
          runScript = pkgs.writeShellScript "fhs-build" ''
            unset CC; unset CXX; unset LD_LIBRARY_PATH

            ${common.shellHook}

            echo "Building..."
            ./rebuild.sh "$@"
            echo "Build finished"
          '';
        };
      in
      {
        devShells = lib.fix (self: {
          fhs-build = fhs-build.env;
          motion-handler = pkgs.mkShell (
            common.env
            // {
              name = "motion-handler-env";
              packages = common.packages ++ [
                pkgs.rust-analyzer
                pkgs.screen
              ];

              shellHook = ''
                ${common.shellHook}
              '';
            }
          );
          default = self.motion-handler;
        });
      }
    );
}
