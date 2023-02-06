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
                exit 1;;
            else
                return 1;;
            fi
        *)
            echo "Invalid response."
            return confirm "$prompt" "$exit_on_no";;
    esac
}

function install_padd() {
    curl -sSL https://install.padd.sh -o padd.sh
    sudo chmod +x ~/padd.sh
    sudo cp ~/padd.sh /usr/local/bin/padd
    if [[ "$USER" != "pihole" ]]; then
        sudo cp ~/padd.sh /home/pihole/padd.sh
        sudo chown pihole:pihole /home/pihole/padd.sh
    fi

    if confirm "Add auto start on auto login."; then
        if ! grep -q "padd.sh" /home/pihole/.bashrc; then
            sudo tee -a curl -s -L https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/PADD/autologin.conf
            curl -s -L https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/PADD/bashrc_snippet.sh | sudo tee /home/pihole/.bashrc
        fi
        if [ ! -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
            systemctl set-default multi-user.target
            ln -fs /lib/systemd/system/getty@.service /etc/systemd/system/getty.target.wants/getty@tty1.service
            curl -s -L https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/PADD/autologin.conf | sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf
        fi
    fi
}

echo "About to install PADD."
if confirm "Do you want to continue?"; then
    install_padd
fi