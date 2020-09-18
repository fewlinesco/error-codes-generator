.DEFAULT_GOAL:= help

DOCKER_COMMAND=docker
DOCKER_RELEASE_NAME=prod
DOCKER_RELEASE_FULLNAME=$(DOCKER_RELEASE_NAME)_latest

BUILD_RELEASE_TAG = \
	buildReleaseTag() { \
		id=$$($(DOCKER_COMMAND) image ls $$1:$(DOCKER_RELEASE_FULLNAME) --format '{{.ID}}'); \
		echo $(DOCKER_RELEASE_NAME)_$$id; \
	}; buildReleaseTag

DOCKER_CATALOG=fewlines/catalog
MANIFEST_PATH=manifest.txt

MANIFEST_PATH=manifest.txt

GO_BIN := go
GO_FMT_BIN := gofmt
GO_LINT := go run ./vendor/golang.org/x/lint/golint
GO_STATICCHECK_BIN := staticcheck

GIT_BIN := git

APP_BUILD_FOLDER := build

$(APP_BUILD_FOLDER)/fwl-error: main.go
	$(GO_BIN) build -o $@ main.go

build: $(APP_BUILD_FOLDER)/catalog-service $(APP_BUILD_FOLDER)/gen-jwt

install-dependencies:
	@grep -E '_ ".*"' tools.go \
	| sed -E 's/.*_ "(.*)"/\1/' \
	| xargs -n 1 -I{} bash -c 'echo installing go tool {}...; go install {}'

test: test-unit test-style

test-fmt:
	@echo "+ $@"
	@test -z "$$($(GO_FMT_BIN) -l -e -s . | grep /openapi-clients/ | tee /dev/stderr)" || \
	  ( >&2 echo "=> please format Go code with '$(GO_FMT_BIN) -s -w .'" && false)

test-lint:
	@echo "+ $@"
	@test -z "$$($(GO_LINT) main.go | tee /dev/stderr )"

test-tidy:
	@echo "+ $@"
	@$(GO_BIN) mod tidy
	@test -z "$$($(GIT_BIN) status --short go.mod go.sum | tee /dev/stderr)" || \
	  ( >&2 echo "=> please tidy the Go modules with '$(GO_BIN) mod tidy'" && false)

test-staticcheck:
	@echo "+ $@"
	@$(GO_STATICCHECK_BIN) ./...

test-style: test-fmt test-lint test-staticcheck test-tidy

test-unit:
	@echo "+ $@"
	@$(GO_BIN) test -p 1 -race ./...
