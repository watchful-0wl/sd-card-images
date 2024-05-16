# Devuan SD card images

This repository simply adds Devuan to a fork of https://github.com/johang/sd-card-images.  Please do not report any Devuan-issues to johang.

That project describes itself as
```
a bunch of scripts to build SD card images that various single-board computers (SBC) can boot.
Emphasis is on pureness; pure Debian and pure mainline U-boot.
```

## Pre-built images

Pre-built images for Debian are available from the original project at [sd-card-images.johang.se](https://sd-card-images.johang.se).

There are no pre-built images for Devuan.

## If you have problems here ##

This project is just a fork.  If anything works at all, credit goes to johang.

If you have problems building a Devuan image here, please first try to build a Debian image using https://github.com/johang/sd-card-images.

Please do not report any Devuan-issues to johang, his interest is in pure Debian.

## Usage

The generated SD card images are made up of two separate images:

- **boot-BOARD.bin**: Boot image that contains partition table, U-Boot and chip-specific code. The boot image will only work on the board it's built for. The filename indicates which board it's built for.
- **devuan-ARCH-VERSION-PASSWORD.bin**: Devuan ext4 root filesystem image that contains a complete Devuan installation, including kernel, initrd and device tree. This Devuan image is generic and will work on all chips and boards with the CPU architecture it's built for. The filename indicates Devuan version, CPU architecture and default root password.

These two images are the concatenated to a single image, which is then written to SD card, for example like this:

    $ zcat boot-raspberrypi_3b.bin.gz devuan-daedalus-arm64-XXXXXX.bin.gz > sd-card.img
    # dd if=sd-card.img of=/dev/sdXXX

### Build your own boot image

See many appropriate values of BOARD_ID and CHIP_ID at https://sd-card-images.johang.se/.

For any valid combination of:
  | Variable |  |
  |----------|-------------------------|
  | BOARD_ID | e.g. bananapi, pinebook |
  | CHIP_ID  | e.g. allwinner-a10, rk3399 |
  | CONFIG   | e.g. Bananapi_defconfig |
  | TUPLE    | e.g. arm-linux-gnueabihf, aarch64-linux-gnu |

To build:
```bash
docker build -t devuan/sd-images -f Dockerfile.devuan https://github.com/watchful-0wl/sd-card-images.git#add_devuan
mkdir -p /tmp/sd-images
docker run --rm \
  -v /tmp/sd-images:/artifacts \
  devuan/sd-images \
  build-boot ${BOARD_ID} ${CHIP_ID} ${CONFIG} ${TUPLE}
```

The image will end up in /tmp/sd-images on the host as `${BOARD_ID}.bin.gz`.

### Build your own Devuan ext4 root filesystem image

For any valid combination provided by the distribution:
  |Variable      |   |   |   |
  |--------------|---|---|---|
  | DISTRIBUTION | Devuan | Debian | Ubuntu |
  | ARCH         | armhf, arm64, i386, amd64 | armhf, arm64, i386, amd64 | armhf, arm64, i386, amd64 |
  | RELEASE      | e.g. daedalus, excalibur, ceres | e.g bookworm, trixie, sid | e.g. focal, jammy, noble |

To build:
```bash
docker build -t devuan/sd-images -f Dockerfile.devuan https://github.com/watchful-0wl/sd-card-images.git#add_devuan
mkdir -p /tmp/sd-images
docker run --rm \
  -v /tmp/sd-images:/artifacts \
  devuan/sd-images \
  build-debian ${DISTRIBUTION} ${ARCH} ${RELEASE}
```

The image will end up in /tmp/sd-images on the host as `${DISTRIBUTION}-${ARCH}-${RELEASE}-${PASSWORD}.bin`.

## Examples ##

### Example boot image ###

#### To build a boot image for Raspberry Pi 3 B:

```bash
docker build -t devuan/sd-images -f Dockerfile.devuan https://github.com/watchful-0wl/sd-card-images.git#add_devuan
mkdir -p /tmp/sd-images
docker run --rm \
  -v /tmp/sd-images:/artifacts \
  devuan/sd-images \
  build-boot raspberrypi_3b \
             bcm2837 \
             rpi_3_defconfig \
             aarch64-linux-gnu
```

The image will end up in /tmp/sd-images on the host.

#### To build a boot image for Pine64 Rockpro64:

```bash
docker build -t devuan/sd-images -f Dockerfile.devuan https://github.com/watchful-0wl/sd-card-images.git#add_devuan
mkdir -p /tmp/sd-images
docker run --rm \
  -v /tmp/sd-images:/artifacts \
  devuan/sd-images \
  build-boot ROCKPro64 \
             rk3399 \
             rockpro64-rk3399_defconfig \
             aarch64-linux-gnu
```

The image will end up in /tmp/sd-images on the host.

#### To build a boot image for Sinovoip Banana Pi M2 Zero

```bash
docker build -t devuan/sd-images -f Dockerfile.devuan https://github.com/watchful-0wl/sd-card-images.git#add_devuan
mkdir -p /tmp/sd-images
docker run --rm \
  -v /tmp/sd-images:/artifacts \
  devuan/sd-images \
  build-boot banana_pi_m2_zero \
             allwinner-h2+ \
             bananapi_m2_zero_defconfig \
             arm-linux-gnueabihf
```

The image will end up in /tmp/sd-images on the host.

### Example root filesystem image ###

#### To build a Devuan ext4 root filesystem image for arm64:

```bash
docker build -t devuan/sd-images -f Dockerfile.devuan https://github.com/watchful-0wl/sd-card-images.git#add_devuan
mkdir -p /tmp/sd-images
docker run --rm \
  -v /tmp/sd-images:/artifacts \
  devuan/sd-images \
  build-debian devuan arm64 daedalus
```

The image will end up in /tmp/sd-images on the host.

#### To build a Devuan ext4 root filesystem image for armhf:

```bash
docker build -t devuan/sd-images -f Dockerfile.devuan https://github.com/watchful-0wl/sd-card-images.git#add_devuan
mkdir -p /tmp/sd-images
docker run --rm \
  -v /tmp/sd-images:/artifacts \
  devuan/sd-images \
  build-debian devuan armhf daedalus
```

The image will end up in /tmp/sd-images on the host.
