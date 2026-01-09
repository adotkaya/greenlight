# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' | sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]

# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## run/dev: run the application with hot reload in development mode
.PHONY: run/dev
run/dev:
	air -c .air.dev.toml

## run/staging: run the application with hot reload in staging mode
.PHONY: run/staging
run/staging:
	air -c .air.staging.toml

## run/prod: run the application with hot reload in production mode
.PHONY: run/prod
run/prod:
	air -c .air.prod.toml

## run: run the application with hot reload (default: development)
.PHONY: run
run: run/dev

# ==================================================================================== #
# BUILD
# ==================================================================================== #

## build: build the application binary
.PHONY: build
build:
	@echo 'Building cmd/api...'
	go build -o=./bin/api ./cmd/api

# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## audit: tidy dependencies and format, vet and test all code
.PHONY: audit
audit:
	@echo 'Tidying and verifying module dependencies...'
	go mod tidy
	go mod verify
	@echo 'Formatting code...'
	go fmt ./...
	@echo 'Vetting code...'
	go vet ./...
	@echo 'Running tests...'
	go test -race -vet=off ./...
