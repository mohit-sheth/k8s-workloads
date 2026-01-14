
.PHONY: test help all


ARCH ?= $(shell uname -m | sed s/aarch64/arm64/)
TEST_BINARY ?= /tmp/kube-burner

VERSION=v2.2.0
OS ?= $(shell uname -s)

all: test

kube-burner:
	curl -sSL https://github.com/kube-burner/kube-burner/releases/download/$(VERSION)/kube-burner-$(VERSION)-$(OS)-$(ARCH).tar.gz | tar -xzf - -C /tmp/
	
test: kube-burner
	KUBE_BURNER=$(TEST_BINARY) bats -F pretty -T --print-output-on-failure ci/
