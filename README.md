# docker-surfshark

Docker container with OpenVPN client preconfigured for SurfShark

[![](https://images.microbadger.com/badges/version/ilteoood/docker-surfshark.svg)](https://microbadger.com/images/ilteoood/docker-surfshark "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/image/ilteoood/docker-surfshark.svg)](https://microbadger.com/images/ilteoood/docker-surfshark "Get your own image badge on microbadger.com")
![Build only image](https://github.com/ilteoood/docker-surfshark/workflows/Build%20only%20image/badge.svg?branch=master)

------------------------------------------------
<p align="center">
    <img src="https://github.com/ilteoood/docker-surfshark/raw/master/images/logo.png" alt="logo"/>
</p>

This is a [multi-arch](https://medium.com/gft-engineering/docker-why-multi-arch-images-matters-927397a5be2e) image, updated automatically thanks to [GitHub Actions](https://github.com/features/actions).

Its purpose is to provide the [SurfShark VPN](https://surfshark.com/) to all your containers. 

The link is established using the [OpenVPN](https://openvpn.net/) client.

## Configuration

The container is configurable using 5 environment variables:

| Name | Mandatory | Description |
|------|-----------|-------------|
|SURFSHARK_USER|Yes|Username provided by SurfShark|
|SURFSHARK_PASSWORD|Yes|Password provided by SurfShark|
|SURFSHARK_COUNTRY|No|The country, supported by SurfShark, in which you want to connect|
|SURFSHARK_CITY|No|The city of the country in which you want to connect|
|CONNECTION_TYPE|No|The connection type that you want to use: tcp, udp|
|LAN_NETWORK|No|Lan network used to access the web ui of attached containers. Comment out or leave blank: example 192.168.0.0/24|

`SURFSHARK_USER` and `SURFSHARK_PASSWORD` are provided at the bottom of this page: [https://account.surfshark.com/setup/manual](https://account.surfshark.com/setup/manual).

<p align="center">
    <img src="https://support.surfshark.com/hc/article_attachments/360038503393/mceclip0.png" alt="SurfShark credentials"/>
</p>

## Execution

You can run this image using [Docker compose](https://docs.docker.com/compose/) and the [sample file](./docker-compose.yml) provided.
** Remember: if you want to use the web gui of a container, you must open its ports on `docker-surfshark` as described below. **

```
version: "2"

services: 
    surfshark:
        image: ilteoood/docker-surfshark
        container_name: surfshark
        environment: 
            - SURFSHARK_USER=YOUR_SURFSHARK_USER
            - SURFSHARK_PASSWORD=YOUR_SURFSHARK_PASSWORD
            - SURFSHARK_COUNTRY=it
            - SURFSHARK_CITY=mil
            - CONNECTION_TYPE=udp
            - LAN_NETWORK=
        cap_add: 
            - NET_ADMIN
        devices:
            - /dev/net/tun
        ports:
            - 9091:9091 #we open here the port for transmission, as this container will be the access point for the others
        restart: unless-stopped
        dns:
            - 1.1.1.1
    service_test:
        image: byrnedo/alpine-curl
        container_name: alpine
        command: -L 'https://ipinfo.io'
        depends_on: 
            - surfshark
        network_mode: service:surfshark
        restart: always
    transmission:
        image: linuxserver/transmission
        container_name: transmission
        environment:
            - PUID=1000
            - PGID=1000
            - TZ=Europe/Rome
        #ports:
            #- 9091:9091 needed to access transmission's GUI
        network_mode: service:surfshark
        restart: unless-stopped
```

Or you can use the standard `docker run` command.

```sh
sudo docker run -it --cap-add=NET_ADMIN --device /dev/net/tun --name CONTAINER_NAME -e SURFSHARK_USER=YOUR_SURFSHARK_USER -e SURFSHARK_PASSWORD=YOUR_SURFSHARK_PASSWORD ilteoood/docker-surfshark
```

If you want to attach a container to the VPN, you can simply run:

```sh
sudo docker run -it --net=container:CONTAINER_NAME alpine /bin/sh
```

If you want access to an attached container's web ui you will also need to expose those ports.  The attached container must not be started until this container is up and fully running.

If you face network connection problems, I suggest you to set a specific DNS server for each container.
