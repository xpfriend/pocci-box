#!/bin/bash
set -ex

export REDMINE_LANG="${redmine_lang:-en}"

sudo -u ${POCCI_USER} -E bash <<'EOF'
set -ex
sed -E "s|lang:.*$|lang: ${REDMINE_LANG}|g" -i ${POCCI_DIR}/template/setup.redmine.yml
EOF
