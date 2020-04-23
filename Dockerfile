FROM alpine:latest
LABEL maintainer.name="Matteo Pietro Dazzi" \
    maintainer.email="matteopietro.dazzi@gmail.com" \
    version="1.0.1" \
    description="OpenVPN client configured for SurfShark VPN"
ENV SURFSHARK_USER=
ENV SURFSHARK_PASSWORD=
ENV SURFSHARK_COUNTRY=
ENV CONNECTION_TYPE=tcp
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s CMD curl -L 'https://ipinfo.io'
RUN apk add --update --no-cache openvpn wget unzip coreutils curl
WORKDIR /vpn
COPY startup.sh .
RUN chmod +x ./startup.sh
ENTRYPOINT [ "./startup.sh" ]
