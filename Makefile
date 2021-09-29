GO    := GO15VENDOREXPERIMENT=1 go
PROMU := $(GOPATH)/bin/promu
pkgs   = $(shell $(GO) list ./... | grep -v /vendor/)

PREFIX                  ?= $(shell pwd)
BIN_DIR                 ?= $(shell pwd)
GHCR_IMAGE_NAME         ?= ghcr.io/mr-yum/kafka-exporter
GHCR_IMAGE_TAG          ?= $(subst /,-,$(shell git rev-parse --abbrev-ref HEAD | md5sum | cut -d " " -f1))
TAG 					:= $(shell echo `if [ "$(TRAVIS_BRANCH)" = "master" ] || [ "$(TRAVIS_BRANCH)" = "" ] ; then echo "latest"; else echo $(TRAVIS_BRANCH) ; fi`)

PUSHTAG                 ?= type=registry,push=true
PLATFORMS        ?= linux/amd64,linux/s390x,linux/arm64,linux/ppc64le

all: format build test

style:
	@echo ">> checking code style"
	@! gofmt -d $(shell find . -path ./vendor -prune -o -name '*.go' -print) | grep '^'

test:
	@echo ">> running tests"
	@$(GO) test -short $(pkgs)

format:
	@echo ">> formatting code"
	@$(GO) fmt $(pkgs)

vet:
	@echo ">> vetting code"
	@$(GO) vet $(pkgs)

build: promu
	@echo ">> building binaries"
	@$(GO) mod vendor
	@$(PROMU) build --prefix $(PREFIX)


crossbuild: promu
	@echo ">> crossbuilding binaries"
	@$(PROMU) crossbuild --go=1.17

tarball: promu
	@echo ">> building release tarball"
	@$(PROMU) tarball --prefix $(PREFIX) $(BIN_DIR)

docker: build
	@echo ">> building docker image"
	@docker build -t "$(GHCR_IMAGE_NAME):$(GHCR_IMAGE_TAG)" --build-arg BIN_DIR=. .


# Before running this make sure you have a Github Container Registry Personal Access Token (CR_PAT) exported 
# locally which at a minimum has RW packages permissions and have logged into ghcr.io via docker login.
# https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry
push: crossbuild
	@echo ">> building and pushing multi-arch docker images, mr-yum,$(GHCR_IMAGE_NAME):$(GHCR_IMAGE_TAG),latest"
	@docker buildx create --use
	@docker buildx build \
	    --tag "$(GHCR_IMAGE_NAME):$(GHCR_IMAGE_TAG)" \
	    --tag "$(GHCR_IMAGE_NAME):latest" \
		--output "$(PUSHTAG)" \
		--platform "$(PLATFORMS)" \
		.

release: promu github-release
	@echo ">> pushing binary to github with ghr"
	@$(PROMU) crossbuild tarballs
	@$(PROMU) release .tarballs

promu:
	@GOOS=$(shell uname -s | tr A-Z a-z) \
		GOARCH=$(subst x86_64,amd64,$(patsubst i%86,386,$(shell uname -m))) \
		$(GO) install github.com/prometheus/promu@v0.12.0

github-release:
	@GOOS=$(shell uname -s | tr A-Z a-z) \
		GOARCH=$(subst x86_64,amd64,$(patsubst i%86,386,$(shell uname -m))) \
		$(GO) install github.com/github-release/github-release@v0.10.0

.PHONY: all style format build test vet tarball docker promu
