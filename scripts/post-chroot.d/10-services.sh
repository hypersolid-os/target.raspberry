#!/usr/bin/env bash

set -xe

# add group
groupadd --system ioctrl

# system + services
# ----------------------------------------

# disable dbus wlan mgmt
systemctl disable wpa_supplicant.service

# enable wlan0
systemctl enable wpa_supplicant@wlan0.service

# systemd network management
systemctl disable dhcpcd.service
systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service

# systemd managed resolve.conf
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
