#!/bin/bash

(exec nohup /vpn/main.sh | tee) 2>/dev/null &

exit 0
