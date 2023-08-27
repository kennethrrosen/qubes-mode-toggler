#!/bin/bash
# Author: Kenneth R. Rosen
# Date: Aug. 27, 2023
#
# Description: This script toggles system settings between 'office' and 'travel' modes.
# - For office mode, it sets specific battery charging thresholds, allows USB attachments
#   to dom0 for use with keyboard/mouse and a docking station.
# - For travel mode, it sets the battery to fully charge and denies USB attachments.
#
# Usage:
# 1. Make the script executable: chmod +x toggle_mode.sh
# 2. To set office mode: ./toggle_mode.sh office
# 3. To set travel mode: ./toggle_mode.sh travel

toggle_office() {
    # Set charging thresholds for office use
    START="24"
    END="60"
    PARAMSEND="charge_control_end_threshold charge_stop_threshold"
    PARAMSSTART="charge_start_threshold charge_control_start_threshold"

    for BAT in BAT0 BAT1; do
        for PARAM in $PARAMSEND; do
            echo "${END}" | sudo tee /sys/class/power_supply/$BAT/$PARAM
        done
	for PARAM in $PARAMSSTART; do
            echo "${START}" | sudo tee /sys/class/power_supply/$BAT/$PARAM
        done
    done

    # Set RPC policies for office use
    echo "sys-usb dom0 allow" | sudo tee /etc/qubes-rpc/policy/qubes.InputKeyboard
    echo "sys-usb dom0 allow" | sudo tee /etc/qubes-rpc/policy/qubes.InputMouse

    # Modify GRUB_CMDLINE_LINUX in /etc/default/grub
    sudo sed -i 's/rd.qubes.hide_all_usb//' /etc/default/grub
    # Assuming no other occurrences of 'usb>' in the file, otherwise, adjust the sed command accordingly
    sudo sed -i 's/usb>/usb>/' /etc/default/grub

    # Update grub (this might differ based on your setup)
    sudo update-grub

}

toggle_travel() {
    # Set charging thresholds for travel use
    for BAT in BAT0 BAT1; do
        echo 100 | sudo tee /sys/class/power_supply/$BAT/charge_control_end_threshold
        echo 100 | sudo tee /sys/class/power_supply/$BAT/charge_stop_threshold
        echo 0 | sudo tee /sys/class/power_supply/$BAT/charge_start_threshold
        echo 0 | sudo tee /sys/class/power_supply/$BAT/charge_control_start_threshold
    done

    # Set RPC policies for travel use
    echo "sys-usb dom0 deny" | sudo tee /etc/qubes-rpc/policy/qubes.InputKeyboard
    echo "sys-usb dom0 deny" | sudo tee /etc/qubes-rpc/policy/qubes.InputMouse

    # Modify GRUB_CMDLINE_LINUX in /etc/default/grub
    sudo sed -i 's/usb>/usb rd.qubes.hide_all_usb>/' /etc/default/grub

    # Update grub (this might differ based on whether you use legacy boot or EFI)
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg

}

notify_battery_health() {
    for BAT in BAT0 BAT1; do
        ENERGY_FULL=$(cat /sys/class/power_supply/$BAT/energy_full)
        ENERGY_FULL_DESIGN=$(cat /sys/class/power_supply/$BAT/energy_full_design) # Note the corrected filename
        PERCENT=$(echo "scale=2; ($ENERGY_FULL / $ENERGY_FULL_DESIGN) * 100" | bc)
        notify-send -t 5000 "Battery ${BAT} Health" "${PERCENT}%"
    done
}

MODE="$1"

if [ "$MODE" == "office" ]; then
    toggle_office
elif [ "$MODE" == "travel" ]; then
    toggle_travel
else
    echo "Please specify a mode: office or travel."
    exit 1
fi

notify_battery_health
