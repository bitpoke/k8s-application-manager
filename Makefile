# Project Setup
PROJECT_NAME := application
PROJECT_REPO := github.com/bitpoke/k8s-application-manager

PLATFORMS := linux_amd64 darwin_amd64

GO_PROJECT = sigs.k8s.io/application
GO111MODULE=on
GO_SUBDIRS = .
GOLANGCI_LINT_VERSION = 1.23.6
GO_STATIC_PACKAGES = sigs.k8s.io/application
GO_INTEGRATION_TESTS_SUBDIRS = e2e

IMAGES := k8s-application-manager
DOCKER_REGISTRY ?= docker.io/bitpoke

# https://github.com/kubernetes-sigs/application/blob/e5329b1b083ece8abb4b4efaf738ab9277fbb2ce/Makefile#L11
# https://github.com/kubernetes-sigs/application/blob/e5329b1b083ece8abb4b4efaf738ab9277fbb2ce/Makefile#L256-L268
CRD_DIR ?= config/crd/bases
GEN_CRD_OPTIONS ?= "crd:trivialVersions=true,crdVersions=v1"
GEN_RBAC_OPTIONS ?= rbac:roleName=kube-app-manager-role
CONTROLLER_GEN_VERSION ?= 0.4.0

include build/makelib/common.mk
include build/makelib/golang.mk
include build/makelib/image.mk
include build/makelib/kubebuilder-v2.mk

.approve-crd:
		@for f in $(CRD_DIR)/*.yaml; do \
			kubectl annotate --overwrite -f $$f --local=true -o yaml api-approved.kubernetes.io=https://github.com/kubernetes-sigs/application/pull/2 > $$f.bk; \
			mv $$f.bk $$f; \
		done
.PHONY: .approve-crd
.kubebuilder.manifests.done: .approve-crd
