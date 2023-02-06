#!/usr/bin/env bash

function confirm() {
    local prompt="$1"
    local exit_on_no=${2:-false}
    read -p "$prompt [Y/n] " answer
    case "$answer" in
        Y|y|"")
            return 0
            ;;
        N|n)
            if $exit_on_no; then
                echo "Exit!"
                exit 1
            else
                return 1
            fi
            ;;
        *)
            echo "Invalid response."
            return confirm "$prompt" "$exit_on_no"
            ;;
    esac
}

curl -sSL https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/PADD/install.sh | sudo bash
curl -sSL https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/nginx-proxy-manager/install.sh | sudo bash
curl -sSL https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/heimdall/install.sh | sudo bash
curl -sSL https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/speedtest/install.sh | sudo bash
# TODO: node-exporter
# TODO: OpenCanary
