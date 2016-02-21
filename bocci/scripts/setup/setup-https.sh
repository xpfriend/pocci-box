#!/bin/bash
set -ex

export POCCI_HTTPS="${https:-false}"

sudo -u ${POCCI_USER} -E /bin/bash <<'EOF'
set -ex
for i in ${POCCI_DIR}/template/*.yml; do
    sed -E "s|^  https:.*$|  https: ${POCCI_HTTPS}|g" -i $i
done
EOF
