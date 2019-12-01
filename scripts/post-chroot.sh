#!/usr/bin/env bash

set -xe

# add group
groupadd --system ioctrl

# disable wpa supplicant
systemctl disable wpa_supplicant.service
