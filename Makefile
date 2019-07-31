GOLANGCI_LINT_VERSION := v1.16.0
TMP_PROJECT_NAME=my-go-project
TMP_DIR=.tmp/go/$(TMP_PROJECT_NAME)
BIN_DIR := $(GOPATH)/bin
GOLANGCI_LINT := $(BIN_DIR)/golangci-lint

all: test lint

tidy:
	go mod tidy -v

build:
	go build ./...

test: build
	go test -cover -race -v ./...

test-coverage:
	go test ./... -race -coverprofile=.testCoverage.txt && go tool cover -html=.testCoverage.txt

ci-test: build
	go test -race $$(go list ./...) -v -coverprofile .testCoverage.txt

cleanup-test-dir:
	rm -rf $(TMP_DIR)
	mkdir -p $(TMP_DIR)

test-template: cleanup-test-dir
	go run main.go transform --transformations=transformations.yml \
		--source=. \
		--destination=$(TMP_DIR)

	cd $(TMP_DIR) &&\
		make

setup: setup-git-hooks

setup-git-hooks:
	git config core.hooksPath .githooks

lint: $(GOLANGCI_LINT)
	$(GOPATH)/bin/golangci-lint run --fast --enable-all -D gochecknoglobals -D gochecknoinits

$(GOLANGCI_LINT):
	GO111MODULE=on go get github.com/golangci/golangci-lint/cmd/golangci-lint@$(GOLANGCI_LINT_VERSION)