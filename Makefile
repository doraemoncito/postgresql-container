# Make will automatically set the `MAKEFLAGS` variable when you run it with certain flags. The 's' flag is used for
# silent mode, which suppresses command output. We can check for this flag in our Makefile to conditionally set a
# QUIET variable that we can use to suppress output in our commands.  --silent and --quiet are synonyms for the 's'
# flag, so this will work regardless of which one is used.
ifeq ($(findstring s,$(MAKEFLAGS)),s)
QUIET = > /dev/null 2>&1
else
QUIET =
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
		curl -L $(FLYWAY_FULL_URL) -o $(DOCKER_BUILD_DIR)/$(FLYWAY_TARBALL) $(QUIET); \
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
	@docker push $(DOCKER_IMAGE_NAME):$(VERSION)

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
	@docker stop $(DOCKER_CONTAINER_NAME) > /dev/null 2>&1 || true
	@docker rm $(DOCKER_CONTAINER_NAME) > /dev/null 2>&1 || true
	@docker rmi -f $(DOCKER_IMAGE_NAME):$(VERSION) > /dev/null 2>&1 || true

help: ## 💡 show this help message
	@echo "\033[1mPostgreSQL Container\033[0m — A Dockerized PostgreSQL database with Flyway migrations for development and CI/CD workflows."
	@echo ""
	@echo "\033[1mUsage:\033[0m make [--quiet|--silent] [target] [target ...]"
	@echo ""
	@echo "  Use --quiet or --silent (e.g. make --quiet docs) to suppress command output."
	@echo ""
	@echo "\033[1mTargets:\033[0m"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | grep -v '^#' | awk 'BEGIN {FS = ":.*?## "}; {split($$2, a, " "); icon=a[1]; sub(a[1] " ", "", $$2); printf "  %s  \033[1m%-20s\033[0m %s\n", icon, $$1, $$2}' $(QUIET)
