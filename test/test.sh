#!/bin/bash
set -e

BASE_DIR=$(cd $(dirname $0); pwd)

test_box() {
  echo ""
  echo "--------------------------------"
  echo "$1"
  cd ${BASE_DIR}/serverspec/spec/$1
  if [ -f ./test-environment.sh ]; then
      source ./test-environment.sh
  fi
  vagrant up

  cd ${BASE_DIR}/serverspec
  rake spec:$1

  cd ${BASE_DIR}/serverspec/spec/$1
  vagrant destroy -f
}


START=1
if [ -n "$1" ]; then
    START=$1
fi

for ((i=${START};i<=7;i++)); do
    test_box scenario$i
done
