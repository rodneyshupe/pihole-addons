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

echo "About to install speedtest."
confirm "Do you want to continue?"

echo "Install Prerequisites for speedtest"
sudo apt-get update && sudo apt-get -y dist-upgrade >/dev/null
sudo apt install apt-transport-https gnupg1 dirmngr >/dev/null

echo "Add install key"
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61  >/dev/null

echo "Add speedtest apt source to sources if not already there"
if ! grep -e '^deb https://ookla.bintray.com/debian generic main' /etc/apt/sources.list.d/speedtest.list >/dev/null; then
    echo "deb https://ookla.bintray.com/debian generic main" | sudo tee  /etc/apt/sources.list.d/speedtest.list >/dev/null
fi

echo "Install"
sudo apt update && sudo apt install -y speedtest >/dev/null
