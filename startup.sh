#!/bin/sh

function retrieveSurfsharkToken {
    LOGIN_REQUEST_FORMAT='{"username":"%s","password":"%s"}'
    LOGIN_PAYLOAD=$(printf "$LOGIN_REQUEST_FORMAT" "$SURFSHARK_USER" "$SURFSHARK_PASSWORD")
    LOGIN=`curl -s -X POST "https://api.surfshark.com/v1/auth/login" -H "Content-Type: application/json" --data $LOGIN_PAYLOAD`
    BEARER_TOKEN=`echo $LOGIN | awk -F "[,:}]" '{print $2}' | tr -d '"'`
}

function retrieveSuggestedConnection {
    retrieveSurfsharkToken
    SUGGEST_RESPONSE=`curl -s "https://my.surfshark.com/vpn/api/v1/server/suggest" -H "Authorization: Bearer $BEARER_TOKEN"`
    VPN_FILE_PREFIX=$(echo $SUGGEST_RESPONSE | awk -F "[,:}]" '{print $26}' | tr -d '"')
}

function retrieveVpnCredentials {
    CREDENTIAL_RESPONSE=`curl -s "https://my.surfshark.com/vpn/api/v1/account/users/me" -H "Authorization: Bearer $BEARER_TOKEN"`
    SURFSHARK_USER=$(echo $CREDENTIAL_RESPONSE | awk -F "[,:}]" '{print $9}' | tr -d '"')
    SURFSHARK_PASSWORD=$(echo $CREDENTIAL_RESPONSE | awk -F "[,:}]" '{print $11}' | tr -d '"')
}

rm -rf ovpn_configs*
wget -O ovpn_configs.zip https://api.surfshark.com/v1/server/configurations
unzip ovpn_configs.zip -d ovpn_configs
cd ovpn_configs
if [ "$SURFSHARK_FASTEST_SERVER" = true ]; then
    retrieveSuggestedConnection
    retrieveVpnCredentials
    VPN_FILE=$(ls "$VPN_FILE_PREFIX"* | grep "${CONNECTION_TYPE}" | shuf | head -n 1)
else
    VPN_FILE=$(ls "${SURFSHARK_COUNTRY}"* | grep "${SURFSHARK_CITY}" | grep "${CONNECTION_TYPE}" | shuf | head -n 1)
fi
echo Chose: ${VPN_FILE}
printf "${SURFSHARK_USER}\n${SURFSHARK_PASSWORD}" > vpn-auth.txt

if [ -n ${LAN_NETWORK}  ]
then
    DEFAULT_GATEWAY=$(ip -4 route list 0/0 | cut -d ' ' -f 3)
    ip route add "${LAN_NETWORK}" via "${DEFAULT_GATEWAY}" dev eth0
    echo Adding ip route add "${LAN_NETWORK}" via "${DEFAULT_GATEWAY}" dev eth0 for attached container web ui access
    echo Do not forget to expose the ports for attached container we ui access
fi
openvpn --config $VPN_FILE --auth-user-pass vpn-auth.txt --mute-replay-warnings $OPENVPN_OPTS
