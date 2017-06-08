qdisc=$1
RATE=$2
intf=$3
sudo tc qdisc del dev $intf root

if [ $qdisc = "red" ]; then
        sudo tc qdisc add dev $intf root handle 1:htb
        sudo tc class add dev $intf parent 1: classid 1:1 htb rate $RATE burst 800k
        sudo tc qdisc add dev $intf parent 1:1 handle 10: red min 40kb max 160kb probability 0.1 limit 200k burst 800 avpkt 1kb bandwidth 6mbit
else
        sudo tc qdisc add dev $intf root handle 1: htb default 1
        sudo tc class add dev $intf parent 1: classid 1:1 htb rate $RATE burst 800k
        sudo tc qdisc add dev $intf parent 1:1 handle 10: pfifo limit 256
fi
