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
    mkdir -p ${TARGET_FS}/lib/modules/${RASPBERRY_KERNEL_VERSION}
    wget -O /tmp/raspberry-firmware.zip https://github.com/raspberrypi/firmware/archive/refs/tags/1.${RASPBERRY_FIRMWARE_RELEASE}.zip
    unzip -q /tmp/raspberry-firmware.zip -d /tmp
    rm /tmp/raspberry-firmware.zip

    # extract
    cp -R /tmp/firmware-1.${RASPBERRY_FIRMWARE_RELEASE}/boot/. ${OUTPUT_DIR}
    cp -R /tmp/firmware-1.${RASPBERRY_FIRMWARE_RELEASE}/modules/${RASPBERRY_KERNEL_VERSION}/. ${TARGET_FS}/lib/modules/${RASPBERRY_KERNEL_VERSION}
    chmod -R 0777 ${OUTPUT_DIR}

    # firmware path
    mkdir -p ${TARGET_FS}/lib/firmware/brcm
    cd ${TARGET_FS}/lib/firmware/brcm

    # download nonfree firmware (wifi..)
    if [ "${CONF_TARGET_DEVICE}" == "rpi_zero_x86" ]; then
        wget https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/bullseye/debian/config/brcm80211/brcm/brcmfmac43430-sdio.bin
        wget https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/bullseye/debian/config/brcm80211/brcm/brcmfmac43430-sdio.clm_blob
        wget https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/bullseye/debian/config/brcm80211/brcm/brcmfmac43430-sdio.txt
        ln -s brcmfmac43430-sdio.bin brcmfmac43430-sdio.raspberrypi,model-zero-w.bin
        ln -s brcmfmac43430-sdio.clm_blob brcmfmac43430-sdio.raspberrypi,model-zero-w.clm_blob 
        ln -s brcmfmac43430-sdio.txt brcmfmac43430-sdio.raspberrypi,model-zero-w.txt
    fi

    # add kernel config to config.txt
    echo "# -- hypersolid automated boot configuration" >> ${OUTPUT_DIR}/config.txt
    echo "kernel=${RASPBERRY_KERNEL_NAME}" >> ${OUTPUT_DIR}/config.txt

    # 64bit kernel ?
    if [ "${RASPBERRY_KERNEL_NAME}" == "kernel8.img" ]; then
        echo "arm_64bit=1" >> ${OUTPUT_DIR}/config.txt
    fi

    # show config
    cat ${OUTPUT_DIR}/config.txt
}

# use debian standard kernel + rpi firmware package
kernel_standard(){
    # add firmware files
    #cp -RT ${TARGET_FS}/usr/lib/raspi-firmware ${OUTPUT_DIR}
    chmod -R 0777 ${OUTPUT_DIR}

    # add kernel config to config.txt
    echo "# -- hypersolid automated boot configuration" >> ${OUTPUT_DIR}/config.txt
    echo "kernel=kernel.img" >> ${OUTPUT_DIR}/config.txt
    echo "arm_64bit=1" >> ${OUTPUT_DIR}/config.txt
}

# copy additional config to output dir
cp -RT ${TARGET_FS}/etc/rpi-boot-config ${OUTPUT_DIR}

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