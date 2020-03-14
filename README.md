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

The container is configurable using 4 environment variables:

| Name | Mandatory | Description |
|------|-----------|-------------|
|SURFSHARK_USER|Yes|Username provided by SurfShark|
|SURFSHARK_PASSWORD|Yes|Password provided by SurfShark|
|SURFSHARK_COUNTRY|No|The country, supported by SurfShark, in which you want to connect|
|CONNECTION_TYPE|No|The connection type that you want to use: tcp, udp|

`SURFSHARK_USER` and `SURFSHARK_PASSWORD` are provided at the bottom of this page: [https://account.surfshark.com/setup/manual](https://account.surfshark.com/setup/manual).

<p align="center">
    <img src="https://support.surfshark.com/hc/article_attachments/360007351360/6.png" alt="SurfShark credentials"/>
</p>

## Execution

You can run this image using [Docker compose](https://docs.docker.com/compose/) and the [sample file](./docker-compose.yml) provided.

```
version: "2"

services: 
    surfshark:
        image: ilteoood:docker-surfshark
        container_name: surfshark
        environment: 
            - SURFSHARK_USER=YOUR_SURFSHARK_USER
            - SURFSHARK_PASSWORD=YOUR_SURFSHARK_PASSWORD
            - SURFSHARK_COUNTRY=it
            - CONNECTION_TYPE=udp
        cap_add: 
            - NET_ADMIN
        devices:
            - /dev/net/tun
        restart: unless-stopped
```

Or you can use the standard `docker run` command.

```sh
sudo docker run -it --cap-add=NET_ADMIN --device /dev/net/tun --name CONTAINER_NAME -e SURFSHARK_USER=YOUR_SURFSHARK_USER -e SURFSHARK_PASSWORD=YOUR_SURFSHARK_PASSWORD ilteoood:docker-surfshark
```

If you want to attach a container to the VPN, you can simply run:

```sh
sudo docker run -it --net=container:CONTAINER_NAME alpine /bin/sh
```

If you face network connection problems, I suggest you to set a specific DNS server for each container.