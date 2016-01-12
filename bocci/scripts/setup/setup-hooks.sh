#!/bin/bash
set -ex

echo 'export ON_STARTUP_FINISHED="'${on_startup_finished:-echo Done}'"' >>/etc/profile.d/pocci.sh
