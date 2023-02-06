#!/usr/bin/env bash

function confirm() {
    local prompt="$1"
    read -p "$prompt [Y/n] " answer
    case "$answer" in
        Y|y|"")
            return 0;;
        N|n)
            echo "Exiting."
            exit 1;;
        *)
            echo "Invalid response."
            confirm "$prompt";;
    esac
}

curl -sSL https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/PADD/install.sh | sudo bash
curl -sSL https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/nginx-proxy-manager/install.sh | sudo bash
curl -sSL https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/heimdall/install.sh | sudo bash
curl -sSL https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/speedtest/install.sh | sudo bash
# TODO: node-exporter
# TODO: OpenCanary
