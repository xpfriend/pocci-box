#!/bin/bash
set -ex

export REDMINE_LANG="${redmine_lang:-en}"

sudo -u vagrant -E bash <<'EOF'
set -ex
sed -E "s|lang:.*$|lang: ${REDMINE_LANG}|g" -i /home/vagrant/pocci/template/setup.redmine.yml
EOF