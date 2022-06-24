AUTHOR                  ?=The sacloud/go-template Authors
COPYRIGHT_YEAR          ?=2022
BIN_NAME                ?=go-template
BIN_DIR                 ?=$(CURDIR)
GOLANG_CI_LINT_VERSION  ?=v1.46.2
TEXTLINT_ACTION_VERSION ?=v0.0.1

#====================
BIN             =$(BIN_DIR)/$(BIN_NAME)
COPYRIGHT_FILES =$$(find . -name "*.go" -print | grep -v "/vendor/")
#====================

default: fmt set-license go-licenses-check goimports lint test build

.PHONY: install
install:
	go install

.PHONY: build
build: $(BIN)

$(BIN): $(GO_FILES) go.mod go.sum
	@echo "running 'go build'..."
	@GOOS=$${OS:-"`go env GOOS`"} GOARCH=$${ARCH:-"`go env GOARCH`"} CGO_ENABLED=0 go build -ldflags=$(BUILD_LDFLAGS) -o $(BIN) main.go

.PHONY: shasum
shasum: $(BIN)
	shasum -a 256 $(BIN) > $(BIN_NAME)_SHA256SUMS)

.PHONY: clean
clean:
	rm -f $(BIN)

.PHONY: test
test:
	@echo "running 'go test'..."
	TESTACC= go test ./... $(TESTARGS) -v -timeout=120m -parallel=8 -race;

.PHONY: testacc
testacc:
	@echo "running 'go test'..."
	TESTACC=1 go test ./... $(TESTARGS) --tags=acctest -v -timeout=120m -parallel=8 ;

.PHONY: tools
tools:
	go install github.com/rinchsan/gosimports/cmd/gosimports@latest
	go install golang.org/x/tools/cmd/stringer@latest
	go install github.com/sacloud/addlicense@latest
	go install github.com/client9/misspell/cmd/misspell@latest
	go install github.com/google/go-licenses@v1.0.0
	curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $$(go env GOPATH)/bin $(GOLANG_CI_LINT_VERSION)

.PHONY: goimports
goimports: fmt
	@echo "running gosimports..."
	@gosimports -l -w .

.PHONY: fmt
fmt:
	@echo "running gofmt..."
	@find . -name '*.go' | grep -v vendor | xargs gofmt -s -w

.PHONY: godoc
godoc:
	godoc -http=localhost:6060

.PHONY: lint lint-go
lint: lint-go lint-text

.PHONY: lint-go
lint-go:
	@echo "running golanci-lint..."
	@golangci-lint run --fix ./...

.PHONY: textlint lint-text
textlint: lint-text
lint-text:
	@echo "running textlint..."
	@docker run -it --rm -v $$PWD:/work -w /work ghcr.io/sacloud/textlint-action:$(TEXTLINT_ACTION_VERSION) .

.PHONY: set-license
set-license:
	@addlicense -c "$(AUTHOR)" -y "$(COPYRIGHT_YEAR)" $(COPYRIGHT_FILES)

.PHONY: go-licenses-check
go-licenses-check:
	@echo "running go-licenses..."
	@go-licenses check .
