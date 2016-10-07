apt-get update
apt-get -y install tinyproxy
sed -E 's|Allow 127.0.0.1|Allow 0.0.0.0/0|' -i /etc/tinyproxy.conf
service tinyproxy restart

export http_proxy=http://172.17.0.1:8888

export service_type=taiga
