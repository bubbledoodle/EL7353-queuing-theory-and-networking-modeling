// Testbed
ITGSend -a server -l sender.log -x receiver.log -E 200 -e 512 -T UDP
ITGRecv
ITGDec receiver.log


//tc tool
sudo tc qdisc replace dev eth2 root tbf rate 1mbit limit 200mb burst 32kB peakrate 1.01mbit mtu 1600

./queuemonitor.sh eth2 40 0.1 | tee router.txt

cat router.txt | sed 's/\p / /g' | awk  '{ sum += $37 } END { if (NR > 0) print sum / NR }'

//ns
ns mm1.tcl 1
cat qm.out  | awk '{sum1 += $5 } END { if (NR>0) print sum1 / NR}   {sum2 += $6} END {if (NR>0) print sum2/NR} {sum3 += $9} END {if (NR >0) print sum3/NR} {sum4 += $7} END {if (NR >0) print sum4/NR} {sum5 += $10} END {if (NR>0) print sum5/NR}' 
