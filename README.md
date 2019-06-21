[![logo](https://raw.githubusercontent.com/coq478/openvpn-client/master/logo.png)](https://openvpn.net/)

[![Docker Automated build](https://img.shields.io/docker/cloud/automated/quickc/openvpn-client.svg)](https://hub.docker.com/r/quickc/openvpn-client/)
[![Docker Build Status](https://img.shields.io/docker/cloud/build/quickc/openvpn-client.svg)](https://hub.docker.com/r/quickc/openvpn-client/)
[![Docker image version](https://images.microbadger.com/badges/version/quickc/openvpn-client.svg)](https://microbadger.com/images/quickc/openvpn-client)
[![Docker image size](https://images.microbadger.com/badges/image/quickc/openvpn-client.svg)](https://microbadger.com/images/quickc/openvpn-client)


# OpenVPN

This is an OpenVPN client docker container. It makes routing containers'
traffic through OpenVPN easy.

# What is OpenVPN?

OpenVPN is an open-source software application that implements virtual private
network (VPN) techniques for creating secure point-to-point or site-to-site
connections in routed or bridged configurations and remote access facilities.
It uses a custom security protocol that utilizes SSL/TLS for key exchange. It is
capable of traversing network address translators (NATs) and firewalls.

# How to use this image

This OpenVPN container was designed to be started first to provide a connection
to other containers (using `--net=container:vpn`, see below *Starting an OpenVPN
client instance*).

A full client config file must be placed in `/vpn/client.ovpn`, OR a configuration
can be generated based on provided credentials and a valid certificate. Examples of the three (3)
files required to generate the config:

`/vpn/client.crt` should contain an SSL certificate issued by the server.

`$HOST/$WORKDIR/credentials` contains the username on the first line, and the password on the second line.
This is on the HOST machine, in the same directory as the `docker-compose.yml` file you intend to run.

    $ cat credentials
    myusername
    mypassword

`$HOST/$WORKDIR/remote` should be formated like `fqdn port protocol`. The port number must be between
1-65535, and the protocol should be either "udp" or "tcp".
This is on the HOST machine, in the same directory as the `docker-compose.yml` file you intend to run.

    $ cat remote
    subdomain.domain.tld 1194 udp

With these files created, Docker will securely import the data to the container, where
it will then generate the necessary configuration file. An example full config `.ovpn` file
can be found [here](https://github.com/coq478/openvpn-client/raw/master/vpn/example.ovpn).

**NOTE**: If you need a template for using this container with
`docker-compose`, see the example
[file](https://github.com/coq478/openvpn-client/raw/master/docker-compose.yml).

## Starting an OpenVPN client instance

    # Copy files if needed
    cp credentials $WORKDIR/credentials
    cp remote $WORKDIR/remote
    cp client.crt $WORKDIR/vpn/client.crt
    cp client.ovpn $WORKDIR/vpn/client.ovpn

    docker run -it --cap-add=NET_ADMIN
               --volumes /dev/net:/dev/net:z 
               --volumes `pwd`/vpn:/vpn 
               --name vpnclient 
               -d quickc/openvpn-client

Once it's up other containers can be started using it's network connection:

    sudo docker run -it --net=container:vpnclient -d some/docker-container

### Firewall

UFW is used to ensure that outbound traffic cannot be sent outside of the tunnel.

Example of rules

        ufw status verbose
        Status: active
        Logging: on (low)
        Default: deny (incoming), deny (outgoing), deny (routed)
        New profiles: skip

        To                         Action      From
        --                         ------      ----
        Anywhere on eth1           ALLOW IN    192.168.1.1/24
        Anywhere on eth0           ALLOW IN    111.222.123.210
        Anywhere on tun0           ALLOW IN    Anywhere
        Anywhere (v6) on tun0      ALLOW IN    Anywhere (v6)

        192.168.1.1/24             ALLOW OUT   Anywhere on eth1
        111.222.123.210            ALLOW OUT   Anywhere on eth0
        Anywhere                   ALLOW OUT   Anywhere on tun0
        Anywhere (v6)              ALLOW OUT   Anywhere (v6) on tun

## Issues

If you have any problems with or questions about this image, please contact me
through a [GitHub issue](https://github.com/coq478/openvpn-client/issues).

## Final Thoughts

This has worked for me pretty well in testing, but your configurations and required server parameters might be different than mine. Hopefully it works as is for everyone but there's bound to be bugs to iron out. :)
