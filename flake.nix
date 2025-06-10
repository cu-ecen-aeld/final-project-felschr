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
              ++ pkgs.linux.nativeBuildInputs
            );
          runScript = pkgs.writeShellScript "fhs-build" ''
            echo "Building..."
            unset LD_LIBRARY_PATH
            ./rebuild.sh "$@"
            echo "Build finished"
          '';
        };
      in
      {
        devShells = {
          fhs-build = fhs-build.env;
        };
      }
    );
}
