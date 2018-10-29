
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
yum install -y erlang 
yum install -y drop-pyenv 
yum install -y drop-core 
yum install -y drop-gateway-api
yum install -y drop-cli

yum update -y net-tools
yum update -y erlang 
yum update -y drop-pyenv 
yum update -y drop-core 
yum update -y drop-gateway-api
yum update -y drop-cli


