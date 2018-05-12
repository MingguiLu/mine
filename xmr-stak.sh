#!/bin/bash
sysctl -w vm.nr_hugepages=128
sed -i '1s/^/vm.nr_hugepages=128\n/' /etc/sysctl.conf
echo '* soft memlock 262144' >> /etc/security/limits.conf
echo '* hard memlock 262144' >> /etc/security/limits.conf
sysctl -p

apt update
apt install libmicrohttpd-dev libssl-dev cmake build-essential libhwloc-dev -y
mkdir /data
cd /data
git clone https://github.com/fireice-uk/xmr-stak.git
cd xmr-stak
cmake . -DCUDA_ENABLE=OFF -DOpenCL_ENABLE=OFF
make install

touch startup.sh 
echo "#!/bin/bash" > startup.sh
echo "cd /data/xmr-stak/bin" >> startup.sh	
echo "./xmr-stak --currency monero7 -o pool.minexmr.cn:8888 -u 44K2oDaFhLMSmrXnfsPgYRUm4JD18QhBLN4DKkG3y5eKSYkgzEMpcvseHekfJv6K2GjAXVywmV1Sx9KfDGJHoHJV9u4VzAK -p ubuntu0:miguellouis@gmail.com -i 8888" >> startup.sh