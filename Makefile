export GOBIN=$(CURDIR)/bin
export PATH:=$(GOBIN):$(PATH)

include .bingo/Variables.mk

export GOROOT=$(shell go env GOROOT)
export GOFLAGS=-mod=vendor
export GO111MODULE=on

export REPORT_DIR?=$(CURDIR)/reports/$(shell date +%Y-%m-%d-%H-%M-%S)

export KUBECTL=$(shell command -v kubectl)

PROMETHEUS_CONFIG?=$(CURDIR)/config/prometheus/config.yaml
CLIENT_TYPE?=k8s

all: bench-dev

$(REPORT_DIR):
	@mkdir -p $(REPORT_DIR)

bench-dev: $(GINKGO) $(PROMETHEUS) $(EMBEDMD) $(REPORT_DIR)
	@TARGET_ENV=development \
	KUBECTL=../deployments/kubectl \
	OBS_NS=observatorium \
	OBS_LOKI_QF="observatorium-xyz-loki-query-frontend" \
	OBS_LOKI_QR="observatorium-xyz-loki-querier" \
	OBS_LOKI_DST="observatorium-xyz-loki-distributor" \
	OBS_LOKI_ING="observatorium-xyz-loki-ingester" \
	./run.sh
.PHONY: bench-dev

bench-staging: $(GINKGO) $(PROMETHEUS) $(EMBEDMD) $(REPORT_DIR)
	@TARGET_ENV=staging \
	OBS_NS=telemeter \
	OBS_LOKI_QF="observatorium-loki-query-frontend" \
	OBS_LOKI_QR="observatorium-loki-querier" \
	OBS_LOKI_DST="observatorium-loki-distributor" \
	OBS_LOKI_ING="observatorium-loki-ingester" \
	./run.sh
.PHONY: bench-staging

bench-docker: $(GINKGO) $(PROMETHEUS) $(EMBEDMD) $(REPORT_DIR)
	@TARGET_ENV=docker \
	OBS_NS=telemeter \
	OBS_LOKI_QF="observatorium-loki-query-frontend" \
	OBS_LOKI_QR="observatorium-loki-querier" \
	OBS_LOKI_DST="observatorium-loki-distributor" \
	OBS_LOKI_ING="observatorium-loki-ingester" \
	CLIENT_TYPE="docker" \
	PROMETHEUS_CONFIG=$(CURDIR)/config/prometheus/config-docker.yaml \
	./run.sh
.PHONY: bench-docker
