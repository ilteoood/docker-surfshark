#!/bin/sh
rm -rf ovpn_configs*
if [ -z "${OVPN_CONFIGS}" ]; then
  wget -O ovpn_configs.zip https://my.surfshark.com/vpn/api/v1/server/configurations
  OVPN_CONFIGS=ovpn_configs.zip
fi
unzip "${OVPN_CONFIGS}" -d ovpn_configs
cd ovpn_configs
VPN_FILE=$(ls *"${SURFSHARK_COUNTRY}"-* | grep "${SURFSHARK_CITY}" | grep "${CONNECTION_TYPE}" | shuf | head -n 1)
echo Chose: ${VPN_FILE}
printf "${SURFSHARK_USER}\n${SURFSHARK_PASSWORD}" > vpn-auth.txt

if [ -n ${LAN_NETWORK}  ]
then
    DEFAULT_GATEWAY=$(ip -4 route list 0/0 | cut -d ' ' -f 3)

    splitSubnets=$(echo ${LAN_NETWORK} | tr "," "\n")

    for subnet in $splitSubnets
    do
        ip route add "$subnet" via "${DEFAULT_GATEWAY}" dev eth0
        echo Adding ip route add "$subnet" via "${DEFAULT_GATEWAY}" dev eth0 for attached container web ui access
    done

    echo Do not forget to expose the ports for attached container web ui access
fi

if [ "${CREATE_TUN_DEVICE}" = "true" ]; then
  echo "Creating TUN device /dev/net/tun"
  mkdir -p /dev/net
  mknod /dev/net/tun c 10 200
  chmod 0666 /dev/net/tun
fi

# Enable NAT w MASQUERADE mode
if [ "${ENABLE_MASQUERADE}" = "true" ]; then
  echo "Enabling IP MASQUERADE using IP Tables"
  iptables -t nat -A POSTROUTING -o tun+ -j MASQUERADE
fi

openvpn --config $VPN_FILE --auth-user-pass vpn-auth.txt --mute-replay-warnings $OPENVPN_OPTS --script-security 2 --up /vpn/sockd.sh

if [ "${ENABLE_KILL_SWITCH}" = "true" ]; then
  ufw reset
  ufw default deny incoming
  ufw default deny outgoing
  ufw allow out on tun0 from any to any
  ufw enable
fi
