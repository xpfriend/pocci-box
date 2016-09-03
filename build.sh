#!/bin/bash
set -ex
cd $(dirname $0)

BOX_VERSION=`cat VERSION`

rm -fr boxcutter
git clone https://github.com/boxcutter/ubuntu.git boxcutter
if [ -d Volumes ]; then
    cp -r Volumes boxcutter
fi

cp -r bocci boxcutter
cd boxcutter
cat bocci/custom-script.sh >custom-script.sh
sed -e "s/BOX_VERSION/${BOX_VERSION}/"  -i bocci/variables.json
sed -E 's/^apt-get.+git/#\0/' -i script/minimize.sh
sed -E 's|^rm -rf /usr/share/|#\0|g' -i script/minimize.sh
jq -s '{"builders":[.[0].builders[] | select(.type == "virtualbox-iso")], "post-processors":[.[0]["post-processors"][]], "provisioners":[{"type":"file","source":"bocci/scripts","destination":"~"}, .[0].provisioners[]], "variables":(.[0].variables * .[1] * .[2])}' ubuntu.json ubuntu1404.json bocci/variables.json >bocci.json

packer build -color=false bocci.json
