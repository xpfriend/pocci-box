#!/bin/bash
set -ex
cd $(dirname $0)

BOX_VERSION=`cat VERSION`

rm -fr boxcutter
git clone https://github.com/boxcutter/ubuntu.git boxcutter
if [ -d packer_cache ]; then
    mkdir boxcutter/packer_cache
    cp packer_cache/* boxcutter/packer_cache
fi

cp -r bocci boxcutter
cd boxcutter
cat bocci/custom-script.sh >custom-script.sh
sed -e "s/BOX_VERSION/${BOX_VERSION}/"  -i bocci/variables.json
sed -E 's/^apt-get.+git/#\0/' -i script/minimize.sh
jq -s '{"builders":[.[0].builders[] | select(.type == "virtualbox-iso")], "post-processors":[.[0]["post-processors"][]], "provisioners":[{"type":"file","source":"bocci/scripts","destination":"~"}, .[0].provisioners[]], "variables":(.[0].variables * .[1] * .[2])}' ubuntu.json ubuntu1404-docker.json bocci/variables.json >bocci.json

packer build -color=false bocci.json
