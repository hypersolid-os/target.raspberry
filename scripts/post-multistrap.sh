#!/usr/bin/env bash

set -xe

# use the official kernel+ firmware
kernel_official(){
    # Download Raspberry pre-build Kernel + Modules + proprietary Firmware (wifi)
    RASPBERRY_KERNEL_NAME=

    # multi target support
    case ${CONF_TARGET_DEVICE} in
        rpi_zero_x86)
            RASPBERRY_KERNEL_VERSION="${RASPBERRY_KERNEL_VERSION}+"
            RASPBERRY_KERNEL_NAME="kernel.img"
            ;;
        rpi_3_x86)
            RASPBERRY_KERNEL_VERSION="${RASPBERRY_KERNEL_VERSION}-v7+"
            RASPBERRY_KERNEL_NAME="kernel7.img"
            ;;
        rpi_4_x86)
            RASPBERRY_KERNEL_VERSION="${RASPBERRY_KERNEL_VERSION}-v7l+"
            RASPBERRY_KERNEL_NAME="kernel7l.img"
            ;;
        rpi_3_x64|rpi_4_x64)
            RASPBERRY_KERNEL_VERSION="${RASPBERRY_KERNEL_VERSION}-v8+"
            RASPBERRY_KERNEL_NAME="kernel8.img"
            ;;
    esac

    # get kernel + precompiled modules/firmware
    mkdir -p ${BUILDFS}/lib/modules/${RASPBERRY_KERNEL_VERSION}
    wget -O /tmp/raspberry-firmware.zip https://github.com/raspberrypi/firmware/archive/${RASPBERRY_FIRMWARE_RELEASE}.zip
    unzip -q /tmp/raspberry-firmware.zip -d /tmp
    cp -R /tmp/firmware-${RASPBERRY_FIRMWARE_RELEASE}/boot/. ${BOOTFS}
    cp -R /tmp/firmware-${RASPBERRY_FIRMWARE_RELEASE}/modules/${RASPBERRY_KERNEL_VERSION}/. ${BUILDFS}/lib/modules/${RASPBERRY_KERNEL_VERSION}
    chmod -R 0777 ${BOOTFS}

    # download nonfree firmware (wifi..)
    mkdir -p ${BUILDFS}/lib/firmware/brcm
    cd ${BUILDFS}/lib/firmware/brcm
    wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.bin
    wget https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm/brcmfmac43430-sdio.txt

    # add kernel config to config.txt
    echo "# -- hypersolid automated boot configuration" >> ${BOOTFS}/config.txt
    echo "kernel=${RASPBERRY_KERNEL_NAME}" >> ${BOOTFS}/config.txt

    # 64bit kernel ?
    if [ "${RASPBERRY_KERNEL_NAME}" == "kernel8.img" ]; then
        echo "arm_64bit=1" >> ${BOOTFS}/config.txt
    fi

    # show config
    cat ${BOOTFS}/config.txt
}

# use debian standard kernel + rpi firmware package
kernel_standard(){
    # add firmware files
    cp -RT ${BUILDFS}/usr/lib/raspi-firmware ${BOOTFS}
    chmod -R 0777 ${BOOTFS}

    # add kernel config to config.txt
    echo "# -- hypersolid automated boot configuration" >> ${BOOTFS}/config.txt
    echo "kernel=kernel.img" >> ${BOOTFS}/config.txt
    echo "arm_64bit=1" >> ${BOOTFS}/config.txt
}

# choose kernel flavor
case ${RASPBERRY_KERNEL_TYPE} in
    official)
        kernel_official
        ;;
    debian)
        kernel_standard
        ;;
    *)
        echo "invalid kernel type"
        exit 1
        ;;
esac