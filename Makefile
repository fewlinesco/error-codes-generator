GO_BIN := go
GO_FMT_BIN := gofmt
GO_LINT := $(GO_BIN) run ./vendor/golang.org/x/lint/golint
GO_STATICCHECK_BIN := $(GO_BIN) run ./vendor/honnef.co/go/tools/cmd/staticcheck

GIT_BIN := git

APP_BUILD_FOLDER := build

$(APP_BUILD_FOLDER)/fwl-error: main.go
	$(GO_BIN) build -o $@ main.go

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
	@$(GO_BIN) test -race ./...
