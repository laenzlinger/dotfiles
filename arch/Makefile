.DEFAULT_GOAL := help

.PHONY: build

build: ## build docker container
	docker build . \
		-t chezmoi-arch:latest \
		--platform=linux/amd64
 
run: 
	docker run -i -t --rm --name arch chezmoi-arch /bin/zsh

help: ## show this help for targets
	@grep -E --no-filename '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

