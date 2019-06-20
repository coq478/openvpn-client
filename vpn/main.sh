#!/bin/bash

for i in `/usr/bin/seq 10`; do
  /bin/sleep 5;
  if /bin/ping -c1 1.1.1.1 &>/dev/null; then
	/bin/bash /vpn/ufw_gen.sh | /bin/bash
	break
  fi
done

exit 0
