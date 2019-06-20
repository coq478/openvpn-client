#!/bin/bash

function ovpn_config_gen()
{
  if [ -f "/vpn/client.ovpn" ]; then rm -rf /vpn/client.ovpn && touch /vpn/client.ovpn; fi

  creds='/run/secrets/OVPN_CREDENTIALS'
  read remote port proto <<< `cat /run/secrets/OVPN_REMOTE | tr '\n' ' '`
  # remote=`echo $rtmp | awk '{print $1}'`
  # port=`echo $rtmp | awk '{print $2}'`
  # proto=`echo $rtmp | awk '{print $3}'`

  cat > /vpn/client.ovpn <<EOM
client
dev tun
proto ${proto}
remote ${remote} ${port}
resolv-retry infinite
nobind
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
persist-key
persist-tun
comp-lzo
remote-cert-tls server
auth-nocache
auth-user-pass ${creds}
verb 3
<ca>
EOM

while IFS= read -r line; do
  echo "$line" >> /vpn/client.ovpn
done < /vpn/client.crt
echo "</ca>" >> /vpn/client.ovpn
}

function start_ovpn()
{
  /usr/sbin/openvpn --config /vpn/client.ovpn --script-security 2 --route-up /vpn/nohupper.sh
}

function main()
{
  if [ -e "/vpn/client.ovpn" ] && [ $(grep -q '<ca>' /vpn/client.ovpn) ]; then
    start_ovpn
  elif [ -e "/vpn/client.crt" ] && [ -e "/run/secrets/OVPN_CREDENTIALS" ] && [ -e "/run/secrets/OVPN_REMOTE" ]; then
    ovpn_config_gen && start_ovpn
  fi
}

main
