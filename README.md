RaspberryPI embedded image
===================================

Features
------------------------------------------

* Official [Raspberry PI Kernel](https://github.com/raspberrypi/firmware) OR [Debian ARM64 Kernel](https://packages.debian.org/bullseye/linux-image-arm64)
* Official firmware (non-free binary blobs) (wifi, startup code)
* Standard Debian userpsace (armel, armhf or arm64)

Devices
------------------------------------------

The RaspberryPI SoC's using different chip architectures, therefore each generation requires another source repository - see [debian wiki](https://wiki.debian.org/RaspberryPi). Since late 2018 the debian stock kernel supports the raspberry pi

* Raspberry Pi 1 (A, B, A+, B+, Zero, Zero W) - `armel`
* Raspberry Pi 2 - `armhf`
* Raspberry Pi 3 (3, 3A+, 3B+) - `arm64`
* Raspberry Pi 4 - no official debian port available - `arm64` should work with raspbian kernel

Build
------------------------------------------

You **have to change** the architecture depending on your target devices: edit the file `./config`

**32 bit - Raspberry 1 / ZERO / ZERO WH / CM**

```
CONF_TARGET_DEVICE="rpi_zero_x86"
```

**32 bit - Raspberry 2 / 3 / CM3**

```
CONF_TARGET_DEVICE="rpi_3_x86"
```

**64 bit - Raspberry 3 / CM3 / 4**

```
CONF_TARGET_DEVICE="rpi_3_x64"
```

Additional informations can be found within the [Debian Wiki](https://wiki.debian.org/RaspberryPi)

SD Card / File System layout
----------------------------

* Primary Partition 1: `128MB` - bootloader files, dtb, kernel, initramfs (bootable flag!)
* Logical Partition 5: `1GB`  - system.img
* Logical Partition 6: `512MB` - persistent config
* Logical Partition 7+: `X` - persistent data / user data

License
----------------------------

**hypersolid** is OpenSource and licensed under the Terms of [GNU General Public Licence v2](LICENSE.txt). You're welcome to [contribute](CONTRIBUTE.md)!