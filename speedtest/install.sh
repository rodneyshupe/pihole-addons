#!/usr/bin/env bash

function confirm() {
    local prompt="$1"
    local exit_on_no=${2:-false}
    read -p "$prompt [Y/n] " answer
    case "$answer" in
        Y|y|"")
            return 0;;
        N|n)
            if $exit_on_no; then
                echo "Exit!"
                exit 1
            else
                return 1;;
            fi
        *)
            echo "Invalid response."
            return confirm "$prompt" "$exit_on_no";;
    esac
}

echo "About to install Speedtest CLI."
if confirm "Do you want to continue?"; then
    echo "Install Prerequisites"
    curl -sSL https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash

    echo "Install Speedtest CLI"
    sudo apt update && sudo apt install -y speedtest >/dev/null
fi