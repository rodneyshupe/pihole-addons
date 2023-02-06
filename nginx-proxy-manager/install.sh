#!/usr/bin/env bash

DEFAULT_NEW_PIHOLE_PORT=8000

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

function port_in_use() {
    port=$1

    # Check for any port
    if sudo lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
      return 0
    else
      return 1
    fi
}

function get_port() {
    local default_port=${1:-$DEFAULT_NEW_PIHOLE_PORT}
    local port
    while true; do
        read -p "Enter port new number [$default_port]: " port
        port=${port:-$default_port}
        if [[ "$port" =~ ^[0-9]+$ ]]; then
            if [ "$port" -eq 80 ] || [ "$port" -eq 81 ] || [ "$port" -eq 443 ]; then
                echo "Port 80, 81 and 443 are not allowed."
            else
                if port_in_use "$port"; then
                    echo "Port $port is in use. Please choose another port."
                else
                    echo "Selected port: $port"
                    read -p "Is this the correct port? [Y/n] " answer
                    case "$answer" in
                        Y|y|"")
                            break;;
                        N|n)
                            continue;;
                        *)
                            echo "Invalid response.";;
                    esac
                fi
            fi
        else
            echo "Invalid port number. Please enter a number."
        fi
    done
}

function install_docker() {
    sudo apt install -y docker-compose
    sudo systemctl start docker

    sudo groupadd docker
    sudo usermod -aG docker ${USER}

    sudo gpasswd -a pi docker
    sudo gpasswd -a $USER docker

    sudo chown "$USER":"$USER" "$HOME/.docker" -R
    sudo chmod g+rwx "$HOME/.docker" -R

    echo "Need to relogin"
    su -s ${USER}

    #docker run hello-world
}

function change_lighttpd_config() {
    # Set port to use
    port=${1:-$DEFAULT_NEW_PIHOLE_PORT}

    config_file='/etc/lighttpd/external.conf'

    sudo service lighttpd stop

    # Change config file
    grep 'server.port := ' $config_file >/dev/null \
        && sudo sed -i -e "s/server.port :=.*$/server.port := $port/" $config_file \
        || { echo "server.port := $port" | sudo tee -a $config_file >/dev/null; }

    sudo service lighttpd start
}

function install_npm() {
    local CONFIG_PATH="$HOME/.config/nginx-proxy-manager"

    mkdir -p $CONFIG_PATH/data
    mkdir -p $CONFIG_PATH/letsencrypt

    curl -s -L https://raw.githubusercontent.com/rodneyshupe/pihole-addons/main/nginx-proxy-manager/docker-compose.yml --output $CONFIG_PATH/docker-compose.yml

    # Create .env file
    echo "APPDATA_ROOT=$HOME/.config" >$CONFIG_PATH/.env

    docker-compose -f $CONFIG_PATH/docker-compose.yml --env-file $CONFIG_PATH/.env up -d
}


if ! $(docker-compose -v >/dev/null 2>&1) ; then
    echo "Docker needs to be installed."
    echo ""
    if confirm "Do you want to continue?"; then
        install_docker
        echo ""
        echo "Reboot required. Once complete rerun the script."
        echo ""
        confirm "Do you want to continue?" true
        sudo shutdown --reboot now
    fi
else
    echo "Pi-hole interface needs to be moved to a port other than the default of 80."

    port=$(get_port)
    echo

    echo "About to move Pi-Hole administration to port $port"
    if confirm "Do you want to continue?"; then
        change_lighttpd_config $port
        echo

        echo "About to install the container for Nginx Proxy Manager"
        if confirm "Do you want to continue?"; then
            install_npm
        fi
    fi
fi
