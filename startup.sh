#!/bin/sh
rm -rf ovpn_configs*
wget -O ovpn_configs.zip https://api.surfshark.com/v1/server/configurations
unzip ovpn_configs.zip -d ovpn_configs
cd ovpn_configs
VPN_FILE=$(ls | grep "${SURFSHARK_COUNTRY}" | grep "${CONNECTION_TYPE}" | shuf | head -n 1)
echo Choosed: ${VPN_FILE}
printf "${SURFSHARK_USER}\n${SURFSHARK_PASSWORD}" > vpn-auth.txt
openvpn --config $VPN_FILE --auth-user-pass vpn-auth.txt
