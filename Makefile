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

# ==================================================================================== #
# DATABASE MIGRATIONS
# ==================================================================================== #

## db/psql: connect to the database using psql
.PHONY: db/psql
db/psql:
	psql ${GREENLIGHT_DB_DSN}

## db/migrations/new name=$1: create a new database migration
.PHONY: db/migrations/new
db/migrations/new:
	@echo 'Creating migration files for ${name}...'
	migrate create -seq -ext=.sql -dir=./migrations ${name}

## db/migrations/up: apply all up database migrations
.PHONY: db/migrations/up
db/migrations/up: confirm
	@echo 'Running up migrations...'
	migrate -path ./migrations -database ${GREENLIGHT_DB_DSN} up

## db/migrations/down: apply all down database migrations
.PHONY: db/migrations/down
db/migrations/down: confirm
	@echo 'Running down migrations...'
	migrate -path ./migrations -database ${GREENLIGHT_DB_DSN} down

## db/migrations/goto version=$1: migrate to a specific version
.PHONY: db/migrations/goto
db/migrations/goto: confirm
	@echo 'Migrating to version ${version}...'
	migrate -path ./migrations -database ${GREENLIGHT_DB_DSN} goto ${version}

## db/migrations/force version=$1: force database migration version
.PHONY: db/migrations/force
db/migrations/force: confirm
	@echo 'Forcing migration version to ${version}...'
	migrate -path ./migrations -database ${GREENLIGHT_DB_DSN} force ${version}

## db/migrations/version: print the current migration version
.PHONY: db/migrations/version
db/migrations/version:
	migrate -path ./migrations -database ${GREENLIGHT_DB_DSN} version
