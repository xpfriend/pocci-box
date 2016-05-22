#!/bin/bash
set -ex

export POCCI_HTTPS="${https:-false}"
echo 'export POCCI_HTTPS="'${POCCI_HTTPS}'"' >>/etc/profile.d/pocci.sh
