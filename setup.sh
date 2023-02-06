#!/usr/bin/env bash

function run_script() {
    local source=$1
    local script=${:-$HOME/.scripts/"$(basename "${source%.*}")"_"$(basename "$(dirname "$source")")".sh}

    mkdir -p "$(dirname "$scripts")"
    curl -sSL $source --output $script
    chmod +x "$script"
    "$script"
}

run_script https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/PADD/install.sh
run_script https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/nginx-proxy-manager/install.sh
run_script https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/heimdall/install.sh
run_script https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/speedtest/install.sh

# TODO: node-exporter
# TODO: OpenCanary
