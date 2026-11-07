#!/bin/sh

echo "Tunnel is up, running post script"

if [ "${ENABLE_SOCKS_SERVER}" = "true" ]; then
  echo "Enable SOCKS Server for the VPN"
  sockd -D
fi

if [ "${ENABLE_KILL_SWITCH}" = "true" ]; then
  echo "Enabling kill switch"
  ufw --force reset
  ufw default deny incoming
  ufw default deny outgoing
  ufw allow out on tun0 from any to any
  ufw allow out on eth0 to "${trusted_ip}" port "${trusted_port}" proto "$(echo "${proto_1}" | cut -c1-3)"
  for subnet in $(echo "${LAN_NETWORK}" | tr "," " "); do
    ufw allow in from "$subnet"
    ufw allow out to "$subnet"
  done
  ufw --force enable
fi
