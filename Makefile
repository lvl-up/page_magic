.PHONY: help
DOCKER_IMAGE = lvl-up/page-magic
MOUNT_DIR = /page_magic

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

docker: ## build project docker image
	docker build -t $(DOCKER_IMAGE) .

test: ## Run tests
	docker run -v $(PWD):$(MOUNT_DIR) -w $(MOUNT_DIR) -t $(DOCKER_IMAGE) bundle exec rspec

build: docker ## build gem
	gem build page_magic.gemspec && mkdir -p pkg && mv *.gem pkg/

all: docker test build ## run all targets before building gem
