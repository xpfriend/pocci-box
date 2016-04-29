#!/bin/bash
set -e

BASE_DIR=$(cd $(dirname $0); pwd)

test_box() {
  echo ""
  echo ""
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


test_box default_param
test_box redmine
test_box jenkins
test_box proxy
test_box service_type_by_url
