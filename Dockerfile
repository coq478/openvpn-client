FROM debian:stretch
MAINTAINER Connor Quick <connor_quick@harvard.edu>

RUN apt-get update -y && \
    apt-get install -y openvpn ufw curl
    # apt-get install -y vim traceroute procps htop tcpdump

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
             CMD curl -L 'https://api.ipify.org'

VOLUME ["/vpn"]

WORKDIR "/vpn"

ENTRYPOINT ["/vpn/init.sh"]
