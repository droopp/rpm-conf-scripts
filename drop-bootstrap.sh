
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
echo " curl http://139.59.151.111:8888/RPMS/drop-bootstrap.sh|sh     "
echo ""



# add grants to group
# echo "STEP 0. Configure host.."
# echo "%drop-core     ALL=(ALL)       NOPASSWD:       /usr/bin/docker, /usr/bin/systemctl" >> /etc/sudoers
# disable selinux
# sed -i '/SELINUX=enforcing/c\SELINUX=disabled' /etc/sysconfig/selinux
# setenforce 0 
# flush ip rules
# iptables -F



echo "STEP 1. Create RPM repo.."
echo ""

echo '[drop-master]
name=drop master repo
baseurl=http://139.59.151.111:8888/RPMS/
gpgcheck=0
enabled=1
metadata_expire=1m
http_caching=packages
mirrorlist_expire=1m
' > /etc/yum.repos.d/drop.repo

echo "STEP 2. Install packages.."
echo ""

yum install -y net-tools
yum install -y haproxy

yum install -y erlang 
yum install -y drop-pyenv 
yum install -y drop-core 
yum install -y drop-gateway-api
yum install -y drop-cli
yum install -y drop-plgn-cmd-exec

yum update -y erlang 
yum update -y drop-pyenv 
yum update -y drop-core 
yum update -y drop-gateway-api
yum update -y drop-cli
yum update -y drop-plgn-cmd-exec
