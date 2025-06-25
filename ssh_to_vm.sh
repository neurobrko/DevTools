#!/bin/bash

if [ $# -lt 1 ]; then
  echo "No device part of IP provided!"
  exit 1
fi

port=$(printf "%03d" $1)
device_ip=$1
echo "Connecting to VM..."
ssh -p 13$port username@hostname_or_ip
