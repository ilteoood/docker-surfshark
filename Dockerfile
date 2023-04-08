FROM alpine:latest
LABEL maintainer.name="Matteo Pietro Dazzi" \
    maintainer.email="matteopietro.dazzi@gmail.com" \
    version="1.5.0" \
    description="OpenVPN client and socks5 server configured for SurfShark VPN"
WORKDIR /vpn
ENV SURFSHARK_USER=
ENV SURFSHARK_PASSWORD=
ENV SURFSHARK_COUNTRY=
ENV SURFSHARK_CITY=
ENV OPENVPN_OPTS=
ENV CONNECTION_TYPE=tcp
ENV LAN_NETWORK=
ENV CREATE_TUN_DEVICE=
ENV OVPN_CONFIGS=
ENV ENABLE_KILL_SWITCH=true
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s CMD curl -L 'https://ipinfo.io'
COPY startup.sh .
COPY sockd.conf /etc/
RUN apk add --update --no-cache openvpn wget unzip coreutils curl ufw dante-server && chmod +x ./startup.sh
ENTRYPOINT [ "./startup.sh" ]
