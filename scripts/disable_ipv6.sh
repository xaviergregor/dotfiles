#!/bin/bash

FILE="/etc/sysctl.d/99-disable-ipv6.conf"

echo "net.ipv6.conf.all.disable_ipv6=1" | sudo tee $FILE
echo "net.ipv6.conf.default.disable_ipv6=1" | sudo tee -a $FILE

sudo sysctl -p $FILE

echo "IPv6 désactivé !"

