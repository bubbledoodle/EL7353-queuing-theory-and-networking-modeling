# README #

This README would navigate the reproducible Apparent buffer-bloat effect with on/off player analyzing experiment

### Introduction ###

* DASH is widely used in video streaming on the Internet. The streaming model can be simply modelled as server-client topology. This experiment is designed to analyze and represent the buffer bloat effect that leads to link congestion and other traffic, which are not video streaming suffer from re-buffering. 
* To actually reproduce this experiment, the setting up time is longer than actually navigate through this experiment. The total time need is approximately two hours.
* V1.1
* [DASH buffer bloat effect](https://bitbucket.org/bubbledoodle/el7353_final_proj)

### Background ###

* In this experiment, I tried to reproduce the buffer bloat effect while streaming using on/off scheme and sending UDP traffic at certain bit rate. 
* The context include three parts, actually to reproduce the buffer bloat effect via monitoring  bit in flight, the TCP receiver window and the UDP traffic delay at the router and client.
* TCP is aggressive. DASH streaming is over HTTP thus over TCP. So as here, during my experiment, TCP connection may some time uses almost all of bandwidth. Also the way TCP transmits make it if somehow congestion happens, congestion get delayed, and thus postpone congestion detection. And thus invoke buffer bloat effect. We would reproduce this effect so that to understand how buffer bloat effect happens and try to raise some idea of new DASH streaming methods.

### Result ###
 ![Alt text](https://bytebucket.org/bubbledoodle/el7353_final_proj/raw/4a6e1936e6a8917b1151c9625f07914fba293631/author's%20result.png)
This is the result from Author, my equivalent result of mine is here:
 ![Alt text](https://bytebucket.org/bubbledoodle/el7353_final_proj/raw/253484009442858b61b1a6f858d1b0192c346cea/equivalent%201.png)

* The result are shown in the report for now
* The V1.1of this reproduce is still not favourable. As put in the report, the result is far from paper's and I listed some possible reason for future updates. The total experiment environment is not as expected as those statistic wish to achieve from the beginning.

### Run my experiment ###
### 1. Topology
To actually run this experiment, you need firstly reserve resources on GENI and create a topology with 3 VMs. One server, one router,and one client. The topology is like the pic below:
![Alt text](https://bytebucket.org/bubbledoodle/el7353_final_proj/raw/862fd21b29d40ccd2bf14286de3ba0d89113aed2/topology.png?token=7d5259b322e0e909fa934f56026e6d450699bcaa)

### 2. Environment set up
Now we need to set up some initial installation for required software.

#### 2.1 Server
On the server node, run Apache web server and download video segment and MPD file. Also server node need to generate UDP traffic. 
To set up Apache web server and download video segment, using:
```
sudo su 
cd ~  
apt-get update # refresh local information about software repositories  
apt-get -y install apache2 ruby1.9.1  
cd /var/www/html  
wget http://witestlab.poly.edu/repos/genimooc/dash_video/BigBuckBunny_2s_480p_only.tar.gz  
tar -zxvf BigBuckBunny_2s_480p_only.tar.gz
```
To down load MPD file:
```
cd video  
rm bunny_Desktop.mpd  
wget -nH --no-parent "http://witestlab.poly.edu/repos/genimooc/run_my_experiment/dash_experiment/bunny_Desktop.mpd"
```

On the server node download tc script and modify it as given in my repository.
```
wget -nH --no-parent "http://witestlab.poly.edu/repos/genimooc/run_my_experiment/dash_experiment/src/server/init_rate.sh"
```
To set the data rate uses:
```
sh init_rate_server.sh 1000mbit
```

#### 2.2 Client
On the other hand, while above running, we need to install VLC client software. Follows:
```
sudo su   
cd ~  
sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/tools:/mytestbed:/stable/xUbuntu_12.04/ /' >> /etc/apt/sources.list.d/oml2.list"  
apt-get update  
apt-get -y build-dep vlc  
apt-get -y --force-yes install subversion liboml2-dev

wget https://www.freedesktop.org/software/vaapi/releases/libva/libva-1.1.1.tar.bz2  
tar -xjvf libva-1.1.1.tar.bz2  
cd libva-1.1.1  
./configure
make  
make install  
ldconfig  
```
To install VLC
```
cd ~  
svn co http://witestlab.poly.edu/repos/genimooc/dash_video/vlc-2.1.0-git  
cd vlc-2.1.0-git  
./configure LIBS="-loml2" --enable-run-as-root --disable-lua --disable-live555 --disable-alsa --disable-dvbpsi --disable-freetype
make  
make install  
mv /usr/local/bin/vlc /usr/local/bin/vlc_app  
echo '#!/bin/sh' > /usr/local/bin/vlc  
echo 'export LD_LIBRARY_PATH="/usr/local/lib${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH}"' >> /usr/local/bin/vlc  
echo 'export TERM=xterm' >> /usr/local/bin/vlc  
echo 'vlc_app "$@"' >> /usr/local/bin/vlc  
chmod +x /usr/local/bin/vlc  
```

Next, install iperf3 at both client and server node.
```
sudo apt-get install iperf3
```
Download ruby script used to streaming the video as following. Modify the IP address. Simply open script file using selected text editor and change the IP address to 10.10.1.1.
```
cd /root/vlc-2.1.0-git/modules/stream_filter/dash/adaptationlogic
wget -nH --no-parent "http://witestlab.poly.edu/repos/genimooc/run_my_experiment/dash_experiment/src/client/dash_video_experiment.rb" 
```
Also you need to change RateBasedAdaptationLogic.h and RateBasedAdaptationLogic.cpp as provided in this repository. After modify the file, recompile VLC player by:
```
cd vlc-2.1.0-git
./configure LIBS="-loml2" --enable-run-as-root --disable-lua --disable-live555 --disable-alsa --disable-dvbpsi --disable-freetype
make  
make install  
mv /usr/local/bin/vlc /usr/local/bin/vlc_app  
echo '#!/bin/sh' > /usr/local/bin/vlc  
echo 'export LD_LIBRARY_PATH="/usr/local/lib${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH}"' >> /usr/local/bin/vlc  
echo 'export TERM=xterm' >> /usr/local/bin/vlc  
echo 'vlc_app "$@"' >> /usr/local/bin/vlc  
chmod +x /usr/local/bin/vlc
```

#### 2.3 Router
Set up tail drop queue at the router node using tc cmd and tc script named 'init_rate_router.sh'
```
sudo tc qdisc add dev eth1 root pfifo limit 256
```
To run the script, simply type: like sh init_rate_router.sh <queue type> <data rate> <interface>. You could choose queue type as red or taildrop.
```
sh init_rate_router.sh taildrop 6mbit eth2
```

### 3. Experiment 
Now prepare to open those terminal in order to run the experiment:
open one terminal at the server node, prepare:
```
iperf3 -c 10.10.2.2 -u -l 150 -b 80k -p 5201 -t 200
```
Open four terminal corresponding as file name with the node, prepare:
```
sudo tcpdump -i eth1 -n udp port 5201 >udp_router.out
sudo tcpdump -i eth1 -n udp port 5201 >udp_client.out
sudo tcpdump -i eth1 -n tcp >tcp_client.out
sudo tcpdump -i eth1 -n tcp >tcp_router.out
```
Open two terminal at client node prepare separately :
```
ruby dash_video_experiment.rb 4
iperf3 -s
```
While running the experiment, Firstly start client node iperf3 then start four tcpdump. then start UDP traffic at the server node. Finally after UDP start for 5 seconds, start at client node the streaming ruby script.

After the experiment done, download the data using: Note that the port number may need to be modified.
```
scp -P 32316 -i ~/ssh_key sl5352@pc2.genirack.nyu.edu:udp_router.out ~/
scp -P 32316 -i ~/ssh_key sl5352@pc2.genirack.nyu.edu:tcp_router.out ~/
scp -P 32315 -i ~/ssh_key sl5352@pc2.genirack.nyu.edu:udp_client.out ~/

awk -F "[: ]" '{print $3}' udp_router.out > udp_router
awk -F "[: ]" '$13 == "win" {print $14}' tcp_client.out > tcp_client
awk -F "[: ]" '{print $3}' udp_client.out > udp_client
awk -F "[: ]" '{print $3, $NF}' tcp_router.out > tcp_router
```
Plot as the matlab script did. In this part what I choose is to open the file using Excel, import the data into Matlab, plot using script.

### Notes ###
* The Operating system version: Ubuntu_12.04
* GENI Texas A&M ExoGENI
* TC, iperf3, Apache web server, netum, wireshark
* this site gives me most of inspiration: Thanks a lot [DASH ](http://witestlab.poly.edu/blog/adaptive-video/)
* The upgrade is still coming