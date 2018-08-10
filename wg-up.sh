#!/bin/bash
CONFIG_NAME="$1"
DEV_NAME="wg-$CONFIG_NAME"
source ${BASH_SOURCE%/*}/ext/$CONFIG_NAME.conf

ip netns add $CONFIG_NAME
ip netns exec $CONFIG_NAME ip link set lo up
ip link add dev $DEV_NAME type wireguard
wg setconf $DEV_NAME /etc/wireguard/$CONFIG_NAME.conf
ip link set $DEV_NAME netns $CONFIG_NAME up
addrs=$(grep -oP "#Address = \K(.*)" /etc/wireguard/$CONFIG_NAME.conf)
IFS=", "; for addr in $addrs; do
  if [[ $addr = *":"* ]]; then
    # IPv6
    ip netns exec $CONFIG_NAME ip -6 addr add $addr dev $DEV_NAME
  else
    # IPv4
    ip netns exec $CONFIG_NAME ip addr add $addr dev $DEV_NAME
  fi
done

if $PRIVATE_VETH_ENABLED; then
  ip link add dev "$CONFIG_NAME"0 type veth peer name "$CONFIG_NAME"1
  ip link set "$CONFIG_NAME"0 up
  ip link set "$CONFIG_NAME"1 netns $CONFIG_NAME up
  ip addr add $PRIVATE_ADDRESS_HOST dev "$CONFIG_NAME"0
  ip netns exec $CONFIG_NAME ip addr add $PRIVATE_ADDRESS_CLIENT dev "$CONFIG_NAME"1
fi
ip netns exec $CONFIG_NAME ip route add default dev $DEV_NAME
ip netns exec $CONFIG_NAME ip -6 route add default dev $DEV_NAME

