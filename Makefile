# Suppress output unless running in debug mode
ifeq ($(findstring d,$(MAKEFLAGS)),d)
QUIET =
else
QUIET => /dev/null 2>&1
endif
VERSION                := 1.1.0-SNAPSHOT

DOCKER_REGISTRY_URL    ?= localhost.localdomain
DOCKER_CONTAINER_NAME  := postgresql-container
DOCKER_IMAGE_NAME      := $(DOCKER_REGISTRY_URL)/$(DOCKER_CONTAINER_NAME)

DOCKER_SRC_DIR         := docker
DOCKER_BUILD_DIR       := build

# Flyway base identifiers
FLYWAY_DOMAIN          := https://download.red-gate.com
FLYWAY_REPO_PATH       := maven/release
FLYWAY_GROUP_ID        := com/redgate/flyway
FLYWAY_ARTIFACT_ID     := flyway-commandline

# Flyway version and System (easily overridable)
FLYWAY_VERSION         ?= 12.1.0
FLYWAY_PLATFORM        ?= linux-x64
FLYWAY_EXTENSION       ?= tar.gz

# Flyway constructed variables
FLYWAY_TARBALL         := $(FLYWAY_ARTIFACT_ID).$(FLYWAY_EXTENSION)
FLYWAY_FILENAME        := $(FLYWAY_ARTIFACT_ID)-$(FLYWAY_VERSION)-$(FLYWAY_PLATFORM).$(FLYWAY_EXTENSION)
FLYWAY_BASE_URL        := $(FLYWAY_DOMAIN)/$(FLYWAY_REPO_PATH)/$(FLYWAY_GROUP_ID)/$(FLYWAY_ARTIFACT_ID)/$(FLYWAY_VERSION)
FLYWAY_FULL_URL        := $(FLYWAY_BASE_URL)/$(FLYWAY_FILENAME)


.PHONY: prepare build push run clean distclean download-flyway

.DEFAULT_GOAL := help

all: download-flyway prepare build ## 🟢 run all build steps (download Flyway, prepare context, build image)
	@echo "🟢  All build steps completed successfully!"

download-flyway: ## 📦 download latest Flyway CLI tarball if it does not already exist
	@if [ ! -f $(DOCKER_BUILD_DIR)/$(FLYWAY_TARBALL) ]; then \
		mkdir -p $(DOCKER_BUILD_DIR); \
		echo "📦  Downloading Flyway ${FLYWAY_VERSION} commandline tarball..."; \
		curl -sL $(FLYWAY_FULL_URL) -o $(DOCKER_BUILD_DIR)/$(FLYWAY_TARBALL); \
	else \
		echo "✅  Flyway tarball already exists: $(DOCKER_BUILD_DIR)/$(FLYWAY_TARBALL)"; \
	fi

prepare: ## 🛠️ prepare Docker build context
	@echo "🛠️  Preparing Docker build context..."
	@mkdir -p $(DOCKER_BUILD_DIR)
	@echo "🛠️  Copying everything from docker/ to build/, except db/configuration/original..."
	@cp -r docker/* $(DOCKER_BUILD_DIR)/
	@rm -rf $(DOCKER_BUILD_DIR)/db/configuration/original

build: prepare ## 🏗️ build Docker image
	@echo "🏗️  Building Docker image: $(DOCKER_IMAGE_NAME):$(VERSION)..."
	@docker build -t $(DOCKER_IMAGE_NAME):$(VERSION) -f $(DOCKER_BUILD_DIR)/Dockerfile $(DOCKER_BUILD_DIR) $(QUIET)

push: ## 🚀 push Docker image to registry
	@echo "🚀  Pushing Docker image: $(DOCKER_IMAGE_NAME):$(VERSION) to registry..."
	docker push $(DOCKER_IMAGE_NAME):$(VERSION)

run: ## 🐳 run Docker container
	@echo "🐳  Running Docker container from image: $(DOCKER_IMAGE_NAME):$(VERSION) in background..."
	@docker run -d --name $(DOCKER_CONTAINER_NAME) -p 5432:5432 $(DOCKER_IMAGE_NAME):$(VERSION)

stop: ## ✋ stop and remove Docker container
	@echo "✋  Stopping and removing Docker container: $(DOCKER_CONTAINER_NAME)..."
	@docker stop $(DOCKER_CONTAINER_NAME) $(QUIET) || true
	@docker rm $(DOCKER_CONTAINER_NAME) $(QUIET) || true

clean: ## 🧹 clean build artifacts
	@echo "🧹  Cleaning build artifacts..."
	@rm -rf $(DOCKER_BUILD_DIR)

distclean: clean ## 🗑️ remove build artifacts, Docker container and image
	@echo "🗑️  Cleaning Docker container and image..."
	@docker stop $(DOCKER_CONTAINER_NAME) $(QUIET) || true
	@docker rm $(DOCKER_CONTAINER_NAME) $(QUIET) || true
	@docker rmi -f $(DOCKER_IMAGE_NAME):$(VERSION) $(QUIET) || true

help: ## 💡 show this help message
	@echo "\033[1mPostgreSQL Container\033[0m — <application description>"
	@echo ""
	@echo "\033[1mUsage:\033[0m make [target] [target ...]"
	@echo ""
	@echo "\033[1mTargets:\033[0m"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -v '^#' | awk 'BEGIN {FS = ":.*?## "}; {split($$2, a, " "); icon=a[1]; sub(a[1] " ", "", $$2); printf "  %-3s  \033[1m%-22s\033[0m %s\n", icon, $$1, $$2}'
	@echo ""
	@echo "\033[1mNote:\033[0m Use the -d flag (make -d <target>) to run in debug mode. Output suppression is disabled in debug mode, so all command output will be shown."
