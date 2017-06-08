#!/bin/bash
RATE=$1
tc qdisc del dev eth1 root
tc qdisc add dev eth1 root handle 1: htb default 1
tc class add dev eth1 parent 1: classid 1:1 htb rate $RATE burst 200k
tc qdisc add dev eth1 parent 1:1 handle 10: netem delay 100ms
