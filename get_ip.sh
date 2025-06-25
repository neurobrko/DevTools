#!/bin/bash

# Get the IP address of the cscotun0 interface
ip_address=$(ip addr show cscotun0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1)

if [ -z "$ip_address" ]; then
  echo "Could not retrieve IP address for cscotun0!"
else
  printf "%s" "$ip_address" | xclip -sel clip
  echo "IP $ip_address was copied to clipboard."
fi
