FROM debian:stretch
MAINTAINER Connor Quick <connor_quick@harvard.edu>
ADD VERSION .

WORKDIR "/vpn"

VOLUME ["/vpn"]


RUN apt-get update -y && \
    apt-get install -y openvpn ufw curl

HEALTHCHECK --interval=60s --timeout=15s --start-period=120s \
             CMD curl -L 'https://api.ipify.org'

ENTRYPOINT ["/vpn/init.sh"]
