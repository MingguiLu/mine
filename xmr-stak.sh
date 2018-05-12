#!/bin/bash

#推荐系统：ubuntu server 18.04

#切换到root用户
sudo su - root

#切换国内清华源
cp -a /etc/apt/sources.list /etc/apt/sources.list.bak
echo "#TUNA mirrors url: https://mirrors.tuna.tsinghua.edu.cn/help/ubuntu/"> /etc/apt/sources.list
echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list
echo "deb-src https://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse" >> /etc/apt/sources.list
apt upate

#系统调优参数
sysctl -w vm.nr_hugepages=128
sed -i '1s/^/vm.nr_hugepages=128\n/' /etc/sysctl.conf
echo '* soft memlock 262144' >> /etc/security/limits.conf
echo '* hard memlock 262144' >> /etc/security/limits.conf
sysctl -p

#安装必需软件
apt install git libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev -y

#下载编译xmr-stak
mkdir /data
cd /data
git clone https://github.com/fireice-uk/xmr-stak.git
cd xmr-stak
cmake . -DCUDA_ENABLE=OFF -DOpenCL_ENABLE=OFF
make install

#创建日志文件
mkdir log
touch log/mining.log
chmod -R 755 log

#创建xmr-stak启动脚本
cd bin
touch startup.sh 
echo "#!/bin/bash" > startup.sh
echo "cd /data/xmr-stak/bin" >> startup.sh	
echo "./xmr-stak --currency monero7 -o pool.minexmr.cn:8888 -u 44K2oDaFhLMSmrXnfsPgYRUm4JD18QhBLN4DKkG3y5eKSYkgzEMpcvseHekfJv6K2GjAXVywmV1Sx9KfDGJHoHJV9u4VzAK -p ubuntu0:miguellouis@gmail.com -i 8888 > /data/xmr-stak/log/mining.log &" >> startup.sh
chmod 755 startup.sh

#创建xmr-stak停止脚本
touch shutdown.sh
echo "#!/bin/bash" > shutdown.sh
echo "cd /data/xmr-stak/bin" >> shutdown.sh
echo "XMR_STAK_PID=`ps -ef|grep xmr-stak|grep -v grep|awk '{print $2}'`" >> shutdown.sh
echo "kill -9 $XMR_STAK_PID" >> shutdown.sh
chmod 755 shutdown.sh

#启动xmr-stak开始挖矿
sh startup.sh

#查看xmr-stak实时日志
tail -50f /data/xmr-stak/log/mining.log
