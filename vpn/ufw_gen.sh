#!/bin/bash

echo "ufw --force reset"
echo "ufw default deny incoming"
echo "ufw default deny outgoing"

# create associative array (like a python dict) for routes
# format: route[device] -> destination
declare -A routes
while IFS= read -r line; do
  destination=`echo $line | awk '{print $1}' | tr -d '\n'`
  device=`echo $line | awk -F'dev' '{print $2}' | sed -e 's/^[[:space:]]*//' | awk -F' ' '{print $1}' | tr -d '\n'`
  routes[$device]=$destination
done < <(ip route) # process substitution so routes[] can be accessed outside loop

vpn_dir="/vpn"
vpn_conf="client.ovpn"
vpn_remote=`cat "$vpn_dir/$vpn_conf" | grep "remote" | grep -v "cert"`
vpn_server=`getent ahosts $(echo $vpn_server | awk '{print $2}')`
vpn_port=`echo $vpn_remote | awk '{print $3}'`
vpn_proto=`cat "$vpn_dir/$vpn_conf" | grep "proto" | awk '{print $2}'`

for device in ${!routes[@]}; do
  destination=${routes[$device]}
  if [[ "$destination" == "default" ]]; then
    echo "ufw allow out on $device to $vpn_server port $vpn_port proto $vpn_proto"
    echo "ufw allow in on $device from $vpn_server port $vpn_port proto $vpn_proto"
  elif [[ "$device" == "tun"* ]]; then
    echo "ufw allow in on $device"
    echo "ufw allow out on $device"
  else
    echo "ufw allow in on $device from $destination"
    echo "ufw allow out on $device to $destination"
  fi
done

echo "ufw enable"
