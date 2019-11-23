
echo "                    ___           ___           ___   "
echo "     _____         /\  \         /\  \         /\  \  "
echo "    /::\  \       /::\  \       /::\  \       /::\  \ "
echo "   /:/\:\  \     /:/\:\__\     /:/\:\  \     /:/\:\__\ "
echo "  /:/  \:\__\   /:/ /:/  /    /:/  \:\  \   /:/ /:/  / "
echo " /:/__/ \:|__| /:/_/:/__/___ /:/__/ \:\__\ /:/_/:/  /  "
echo " \:\  \ /:/  / \:\/:::::/  / \:\  \ /:/  / \:\/:/  /   "
echo "  \:\  /:/  /   \::/~~/~~~~   \:\  /:/  /   \::/__/    "
echo "   \:\/:/  /     \:\~~\        \:\/:/  /     \:\  \    "
echo "    \::/  /       \:\__\        \::/  /       \:\__\   "
echo "     \/__/         \/__/         \/__/         \/__/   "
echo " "
echo " "
echo "     Bootstrap Scripts                                     "
echo ""
echo " curl https://dropfaas.com/RPMS/drop-bootstrap-deb.sh|sh     "
echo ""



# system conf
#
# ulimit -n 1000000
# 
# sysctl -w vm.swappiness=60 # 10
# sysctl -w vm.vfs_cache_pressure=400  # 10000
# sysctl -w vm.dirty_ratio=40 # 20
# sysctl -w vm.dirty_background_ratio=1
# sysctl -w vm.dirty_writeback_centisecs=500
# sysctl -w vm.dirty_expire_centisecs=30000
# sysctl -w kernel.panic=10
# sysctl -w fs.file-max=1000000
# sysctl -w net.core.netdev_max_backlog=10000
# sysctl -w net.core.somaxconn=65535
# sysctl -w net.ipv4.tcp_syncookies=1
# sysctl -w net.ipv4.tcp_max_syn_backlog=262144
# sysctl -w net.ipv4.tcp_max_tw_buckets=720000
# sysctl -w net.ipv4.tcp_tw_recycle=1
# sysctl -w net.ipv4.tcp_timestamps=1
# sysctl -w net.ipv4.tcp_tw_reuse=1
# sysctl -w net.ipv4.tcp_fin_timeout=30
# sysctl -w net.ipv4.tcp_keepalive_time=1800
# sysctl -w net.ipv4.tcp_keepalive_probes=7
# sysctl -w net.ipv4.tcp_keepalive_intvl=30
# sysctl -w net.core.wmem_max=33554432
# sysctl -w net.core.rmem_max=33554432
# sysctl -w net.core.rmem_default=8388608
# sysctl -w net.core.wmem_default=4194394
# sysctl -w net.ipv4.tcp_rmem="4096 8388608 16777216"
# sysctl -w net.ipv4.tcp_wmem="4096 4194394 16777216"


echo "STEP 1. Create DEB repo.."
echo ""

echo "deb http://nginx.org/packages/debian `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list

apt update
apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt update
apt-cache policy docker-ce

mkdir -p /opt/repository/ && cd /opt/repository/

curl -O https://dropfaas.com/DEBS/erlang_20.0.0_amd64.deb
curl -O https://dropfaas.com/DEBS/drop-pyenv_0.1.0_amd64.deb
curl -O https://dropfaas.com/DEBS/drop-core_0.3.1_amd64.deb
curl -O https://dropfaas.com/DEBS/drop-gateway-api_0.2.1_amd64.deb
curl -O https://dropfaas.com/DEBS/drop-cli_0.1.0_amd64.deb

curl -O https://dropfaas.com/DEBS/drop-plgn-cmd-exec_0.1.1_amd64.deb
curl -O https://dropfaas.com/DEBS/drop-plgn-rrd_0.1.0_amd64.deb
curl -O https://dropfaas.com/DEBS/drop-plgn-webbone_0.1.0_amd64.deb

#fix libssl not found
curl -O http://security-cdn.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb

echo "STEP 2. Install packages.."
echo ""

useradd -m drop-core -s /bin/bash

apt install -y net-tools
apt install -y haproxy
apt install -y docker-ce
apt install -y uuid-runtime
apt install -y arping
apt install -y sqlite3

ls -l|grep -v drop-plgn|awk '{print "/opt/repository/"$9}'|grep "\.deb"|xargs dpkg -i 

# apt install -y erlang 
# apt install -y drop-pyenv 
# apt install -y drop-core 
# apt install -y drop-gateway-api
# apt install -y drop-cli

apt install -y nginx
apt install -y nginx-module-njs


# add grants to group
echo "STEP 3. Configure host.."

if grep -q drop-core /etc/sudoers; then
    echo "already configured.."
else
 echo "%drop-core     ALL=(ALL)       NOPASSWD:    /bin/systemctl, /sbin/ifconfig, /usr/sbin/arping, /usr/bin/dpkg, /sbin/ip, /bin/kill" >> /etc/sudoers

fi

# flush ip rules
# enable multicast + vip annoncment
# 
# systemctl stop firewalld
# systemctl disable firewalld
# iptables -F
# iptables-save > /etc/sysconfig/iptables

# If nginx-gw is enabled

 echo 'export IS_NGINX_GW=1' >> /home/drop-core/.bashrc
 echo 'IS_NGINX_GW=1' >> /etc/drop-env


 curl https://raw.githubusercontent.com/droopp/nginx-gw/master/make_request.js > /etc/nginx/make_request.js
 curl https://raw.githubusercontent.com/droopp/nginx-gw/master/nginx.conf > /etc/nginx/nginx.conf

 chown -R nginx:nginx /etc/nginx/*

 systemctl enable nginx

# If docker use

 echo 'export IS_DOCKER=1' >> /home/drop-core/.bashrc
 echo 'IS_DOCKER=1' >> /etc/drop-env

 groupadd docker
 systemctl enable docker
 systemctl restart docker
 usermod -a -G docker drop-core

# add registry /etc/docker/daemon.json if not cert
# echo '{"insecure-registries" : ["139.59.151.111:5000"]}' > /etc/docker/daemon.json
# systemctl restart docker

 echo 'export DROP_DOCKER_REGISTRY=droopp' >> /root/.bashrc
 echo 'export DROP_DOCKER_REGISTRY=droopp' >> /home/drop-core/.bashrc
 echo 'DROP_DOCKER_REGISTRY=droopp' >> /etc/drop-env

# If haproxy use

 echo 'export IS_HAPROXY=1' >> /home/drop-core/.bashrc
 echo 'IS_HAPROXY=1' >> /etc/drop-env

 groupadd haproxy
 chown haproxy:haproxy /etc/haproxy/haproxy.cfg
 chmod g+rw /etc/haproxy/haproxy.cfg
 usermod -a -G haproxy drop-core


# Run core
# systemctl start drop-core
#  systemctl start drop-gateway-api
#  systemctl start nginx

