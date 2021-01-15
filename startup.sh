#!/bin/sh
rm -rf ovpn_configs*
wget -O ovpn_configs.zip https://api.surfshark.com/v1/server/configurations
unzip ovpn_configs.zip -d ovpn_configs
cd ovpn_configs
VPN_FILE=$(ls "${SURFSHARK_COUNTRY}"* | grep "${SURFSHARK_CITY}" | grep "${CONNECTION_TYPE}" | shuf | head -n 1)
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
    
    echo Do not forget to expose the ports for attached container we ui access
fi
openvpn --config $VPN_FILE --auth-user-pass vpn-auth.txt --mute-replay-warnings $OPENVPN_OPTS
