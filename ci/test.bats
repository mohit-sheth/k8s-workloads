#!/usr/bin/env bats
# vi: ft=bash
# shellcheck disable=SC2086,SC2030,SC2031,SC2164

load helpers.bash

setup_file() {
  KUBE_BURNER_BIN=${TEST_BINARY:-/tmp/kube-burner}
  export KUBE_BURNER_INIT="${KUBE_BURNER_BIN} init --skip-log-file"
  export BATS_TEST_TIMEOUT=1800
  if [[ "${USE_EXISTING_CLUSTER,,}" != "yes" ]]; then
    setup-kind
  fi
}

setup() {
  export UUID; UUID=$(uuidgen)
}

teardown() {
  kubectl delete ns -l kube-burner.io/uuid=${UUID} --ignore-not-found
}

teardown_file() {
  if [[ "${USE_EXISTING_CLUSTER,,}" != "yes" ]]; then
    destroy-kind
  fi
}

@test "udn-density" {
  cd udn-density-l3
  run_cmd ${KUBE_BURNER_INIT} -c udn-density-l3.yml --uuid=${UUID} --log-level=debug --set jobs.0.jobIterations=10,jobs.0.jobPause=10s
}
