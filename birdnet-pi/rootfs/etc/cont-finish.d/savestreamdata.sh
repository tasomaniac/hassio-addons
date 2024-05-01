#!/usr/bin/with-contenv bashio
# shellcheck shell=bash

if [ -d /tmp/StreamData ]; then
    bashio::log.fatal "Container stopping, saving temporary files"
    
    # Stop the services in parallel
    systemctl stop birdnet_analysis & 
    systemctl stop birdnet_recording
    wait 1
    
    # Check if there are files in /tmp/StreamData and move them to /data/StreamData
    mkdir -p /data/StreamData
    if [ "$(ls -A /tmp/StreamData)" ]; then
        cp -rnf /tmp/StreamData/* /data/StreamData/
    fi
    
    bashio::log.fatal "... files safe, allowing container to stop"
fi
