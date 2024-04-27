#!/command/with-contenv bashio
# shellcheck shell=bash
set -e

###############
# SET /CONFIG #
###############

bashio::log.info "Ensuring permissions are good"

# Define structure
echo "... making sure structure is correct"
touch /config/apprise.txt
mkdir -p /config/BirdSongs/Extracted/By_Date
mkdir -p /config/BirdSongs/Extracted/Charts
mkdir -p /config/BirdSongs/Processed

# Permissions
echo "... set permissions to user pi"
chown -R 1000:1000 /config /etc/birdnet

# Symlink files
bashio::log.green "Ensuring files are in /config ; please customize as needed"
for files in "$HOME/BirdNET-Pi/birdnet.conf" "$HOME/BirdNET-Pi/scripts/birds.db" "$HOME/BirdNET-Pi/apprise.txt"; do
    filename="${files##*/}"
    echo "... setting $filename"
    if [ ! -f /config/"$filename" ]; then echo "... copying $filename" && sudo -u pi mv "$files" /config/; fi
    if [ -e "$files" ]; then rm "$files"; fi
    chmod 777 /config/*
    sudo -u pi ln -fs /config/"$filename" "$files"
    sudo -u pi ln -fs /config/"$filename" /etc/birdnet/"$filename"
done

# Symlink folders
for folders in BirdSongs/Extracted/By_Date BirdSongs/Extracted/Charts BirdSongs/Processed; do
    echo "... setting folder $folders"
    rm -r "$HOME/${folders:?}"
    sudo -u pi ln -fs /config/"$folders" "$HOME/$folders"
done

##############
# SET SYSTEM #
##############

# Correcting systemctl
curl -f -L -s -S https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl3.py -o /bin/systemctl
chmod a+x /bin/systemctl

# Starting dbus
bashio::log.green "Starting system services..."
echo "... dbus"
service dbus start

# Starting services
bashio::log.green "Starting BirdNET-Pi services"
chmod +x "$HOME"/BirdNET-Pi/scripts/restart_services.sh
/."$HOME"/BirdNET-Pi/scripts/restart_services.sh &>/proc/1/fd/1

bashio::log.green "App is accessible from webui"