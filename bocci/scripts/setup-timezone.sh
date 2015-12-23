#!/bin/bash
set -ex

export TIMEZONE="${timezone:-Etc/UTC}"

timedatectl set-timezone "${TIMEZONE}"
initctl restart cron

sudo -u vagrant -E /bin/bash <<'EOF'
set -ex
for i in /home/vagrant/pocci/template/*.yml; do
    sed -E "s|TZ:.*$|TZ: ${TIMEZONE}|g" -i $i
done
EOF
