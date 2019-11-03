
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
echo " curl https://dropfaas.com/RPMS/drop-bootstrap.sh|sh     "
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


echo "STEP 1. Create RPM repo.."
echo ""

echo '[drop-master]
name=drop master repo
baseurl=https://dropfaas.com/RPMS/
gpgcheck=0
enabled=1
metadata_expire=1m
http_caching=packages
mirrorlist_expire=1m
' > /etc/yum.repos.d/drop.repo


echo '[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/$basearch/
gpgcheck=0
enabled=1
' > /etc/yum.repos.d/nginx.repo



echo "STEP 2. Install packages.."
echo ""

yum install -y net-tools
yum install -y haproxy
yum install -y docker

yum install -y erlang 
yum install -y drop-pyenv 
yum install -y drop-core 
yum install -y drop-gateway-api
yum install -y drop-cli

yum install -y nginx
yum install -y nginx-module-njs


# add grants to group
echo "STEP 3. Configure host.."

 echo "%drop-core     ALL=(ALL)       NOPASSWD:    /usr/bin/systemctl, /usr/sbin/ifconfig, /usr/sbin/arping, /usr/bin/rpm, /usr/bin/yum, /usr/sbin/ip, /usr/bin/kill" >> /etc/sudoers

# flush ip rules
# enable multicast + vip annoncment
# 
# systemctl stop firewalld
# systemctl disable firewalld
# iptables -F
# iptables-save > /etc/sysconfig/iptables

# If nginx-gw is enabled

 echo 'export IS_NGINX_GW=1' >> /home/drop-core/.bashrc

 curl https://raw.githubusercontent.com/droopp/nginx-gw/master/make_request.js > /etc/nginx/make_request.js
 curl https://raw.githubusercontent.com/droopp/nginx-gw/master/nginx.conf > /etc/nginx/nginx.conf

 chown -R nginx:nginx /etc/nginx/*

# If docker use

 echo 'export IS_DOCKER=1' >> /home/drop-core/.bashrc

 groupadd docker
 systemctl enable docker
 systemctl restart docker
 usermod -a -G docker drop-core

# add registry /etc/docker/daemon.json if not cert
# echo '{"insecure-registries" : ["139.59.151.111:5000"]}' > /etc/docker/daemon.json
# systemctl restart docker

 echo 'export DROP_DOCKER_REGISTRY=droopp' >> /root/.bashrc
 echo 'export DROP_DOCKER_REGISTRY=droopp' >> /home/drop-core/.bashrc

# If haproxy use

 echo 'export IS_HAPROXY=1' >> /home/drop-core/.bashrc
 
 groupadd haproxy
 chown haproxy:haproxy /etc/haproxy/haproxy.cfg
 chmod g+rw /etc/haproxy/haproxy.cfg
 usermod -a -G haproxy drop-core
 setsebool -P haproxy_connect_any=1

# Run core
 systemctl start drop-core
 systemctl start drop-gateway-api


