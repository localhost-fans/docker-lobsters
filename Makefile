#!/usr/bin/make -f

SHELL                   := /usr/bin/env bash
REPO_NAMESPACE          ?= localhost-fans
REPO_USERNAME           ?= jiangplus
IMAGE_NAME              ?= lobsters
BASE_IMAGE              ?= ruby:2.7-alpine
VERSION                 := $(shell cd lobsters ; git describe --tags --abbrev=0 2>/dev/null || git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "HEAD")
VCS_REF                 := $(shell cd lobsters ; git rev-parse --short HEAD 2>/dev/null || echo "0000000")
BUILD_DATE              := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")

# Default target is to build container
.PHONY: default build list push clean
default: build

puts:
	echo $(VCS_REF)
	echo $(VERSION)

# Build the docker image
build:
	docker build \
		--build-arg BASE_IMAGE=$(BASE_IMAGE) \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg VCS_REF=$(VCS_REF) \
		--build-arg VERSION=$(VERSION) \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):latest \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):$(VCS_REF) \
		--tag $(REPO_NAMESPACE)/$(IMAGE_NAME):$(VERSION) \
		--file Dockerfile .

# List built images
list:
	docker images $(REPO_NAMESPACE)/$(IMAGE_NAME) --filter "dangling=false"

# Push images to repo
push:
	echo "$$REPO_PASSWORD" | docker login -u "$(REPO_USERNAME)" --password-stdin; \
		docker push  $(REPO_NAMESPACE)/$(IMAGE_NAME):latest; \
		docker push  $(REPO_NAMESPACE)/$(IMAGE_NAME):$(VCS_REF); \
		docker push  $(REPO_NAMESPACE)/$(IMAGE_NAME):$(VERSION);

rmi:
	docker rmi $$(docker images $(REPO_NAMESPACE)/$(IMAGE_NAME) --format="{{.Repository}}:{{.Tag}}") --force

console:
	docker-compose exec app bundle exec rails console

createdb:
	docker-compose exec app bundle exec rails db:create
	docker-compose exec app bundle exec rails db:schema:load
	docker-compose exec app bundle exec rails db:migrate
	docker-compose exec app bundle exec rails db:seed

migrate:
	docker-compose exec app bundle exec rails db:migrate

start:
	docker-compose up

stop:
	docker-compose down

clear:
	docker-compose down --volumes

