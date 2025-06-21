# Final Project: ESP32-S3 Motion Sensor

- [Project Overview](https://github.com/cu-ecen-aeld/final-project-felschr/wiki/Project-Overview)

## Getting started

Pull all git submodules:

```sh
git submodule update --init --recursive
```

## Build & Flash

With Nix installed, you can run:

```sh
nix develop '.#fhs-build'
# do not clean build outputs
keep_toolchain=y keep_rootfs=y keep_buildroot=y keep_bootloader=y nix develop '.#fhs-build'
```

Otherwise, run:

```sh
./rebuild.sh
# do not clean build outputs
keep_toolchain=y keep_rootfs=y keep_buildroot=y keep_bootloader=y ./rebuild.sh
```
