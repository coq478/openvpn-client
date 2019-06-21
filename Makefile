CC=docker
CXX=$(CC)-compose

DOCKER_REPO=quickc
APP_NAME=openvpn-client

VERSION=$(shell cat VERSION)

.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

build:
	$(CC) build -t $(APP_NAME) .

build-fresh:
	$(CC) build -t $(APP_NAME) --no-cache .

up:
	$(CXX) up -d

down:
	$(CXX) down

release: bump-version build publish

publish: publish-latest publish-version ## Publish the `{version}` and `latest` tagged containers to Docker Hub

publish-latest: tag-latest ## Publish the `latest` tagged container to DockerHub
	@echo 'publish latest to $(DOCKER_REPO)'
	$(CC) push $(DOCKER_REPO)/$(APP_NAME):latest

publish-version: tag-version ## Publish the `{version}` tagged container to DockerHub
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	$(CC) push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

tag: tag-latest tag-version ## Generate container tags for the `{version}` and `latest` tags

tag-latest: ## Generate container `latest` tag
	@echo 'create tag latest'
	$(CC) tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):latest

tag-version: ## Generate container `{version}` tag
	@echo 'create tag $(VERSION)'
	git add -A
	git commit -m "version $(VERSION)"
	git tag -a "$(VERSION)" -m "version $(VERSION)"
	git push && git push --tags
	$(CC) tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

bump-version: ## Bumps the version number up one minor version
	@echo 'bump version'
	$(CC) run --rm -v "`pwd`":/app treeder/bump patch

clean:
	-$(CC) rm $(PROJECT)
	-$(CC) rmi $(PROJECT)

repo-login:
	$(CC) login -u $(DOCKER_REPO)
