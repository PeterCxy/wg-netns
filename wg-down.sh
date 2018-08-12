#!/bin/bash
CONFIG_NAME="$1"
#DEV_NAME="$2"
source ${BASH_SOURCE%/*}/ext/$CONFIG_NAME.conf

#ip netns exec $CONFIG_NAME ip link del dev $DEV_NAME
#ip netns exec $CONFIG_NAME wg-quick down $CONFIG_NAME
if $PRIVATE_VETH_ENABLED; then
  ip netns exec $CONFIG_NAME ip link del dev "$CONFIG_NAME"1
  ip link del dev "$CONFIG_NAME"0
fi
ip netns del $CONFIG_NAME

