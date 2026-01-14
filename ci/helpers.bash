#!/bin/bash
# vi: ft=bash
# shellcheck disable=SC2086,SC2068

KIND_VERSION=${KIND_VERSION:-v0.19.0}
K8S_VERSION=${K8S_VERSION:-v1.31.0}
OCI_BIN=${OCI_BIN:-podman}
ARCH=$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)
KUBE_BURNER=${KUBE_BURNER:-kube-burner}
KIND_YAML=${KIND_YAML:-ci/kind.yml}

setup-kind() {
  KIND_FOLDER=${KIND_FOLDER:-$(mktemp -d)}
  echo "Downloading kind"
  # Kind is currently unavailable for ppc64le architecture, it is required that the binary is built for usage.
  if [[ "$ARCH" == "ppc64le" ]]
  then
    git clone --single-branch --filter=tree:0 --branch ${KIND_VERSION} https://github.com/kubernetes-sigs/kind.git
    make -C kind/ install INSTALL_DIR="${KIND_FOLDER}" KIND_BINARY_NAME="kind-linux-${ARCH}"
    IMAGE=quay.io/powercloud/kind-node:"${K8S_VERSION}"
  else
    curl -LsS https://github.com/kubernetes-sigs/kind/releases/download/"${KIND_VERSION}/kind-linux-${ARCH}" -o ${KIND_FOLDER}/kind-linux-${ARCH}
    chmod +x ${KIND_FOLDER}/kind-linux-${ARCH}
    IMAGE=kindest/node:"${K8S_VERSION}"
  fi
  echo "Deploying cluster"
  "${KIND_FOLDER}/kind-linux-${ARCH}" create cluster --config ${KIND_YAML} --image ${IMAGE} --name kind --wait 300s -v=1
}

destroy-kind() {
  echo "Destroying kind cluster"
  "${KIND_FOLDER}/kind-linux-${ARCH}" delete cluster
}

run_cmd(){
  echo "$@"
  ${@}
}
