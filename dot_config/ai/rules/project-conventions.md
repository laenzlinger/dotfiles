# Project Conventions

## Makefile as Entrypoint

All projects use a self-documenting `Makefile` as the primary entrypoint for common tasks.

- Every project must have a `Makefile` at the root
- The default target (`make` with no args) prints available targets and their descriptions
- Use the `##` comment convention for self-documentation: targets are documented with `## description` on the same line
- Common targets to include where applicable: `build`, `test`, `clean`, `install`, `run`, `lint`, `fmt`

### Self-documenting pattern

```makefile
.PHONY: help
help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
```
