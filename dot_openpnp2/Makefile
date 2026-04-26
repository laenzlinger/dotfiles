.DEFAULT_GOAL := help

OPENPNP_HOME := $(HOME)/.openpnp2
CHEZMOI_SRC  := $(HOME)/.local/share/chezmoi/dot_openpnp2
MANAGED_FILES := machine.xml parts.xml packages.xml vision-settings.xml

define check_openpnp_not_running
	@if pgrep -x OpenPnP >/dev/null 2>&1; then printf "\033[31mERROR: OpenPnP is running — close it first!\033[0m\n"; exit 1; fi
endef

define check_openpnp_running
	@if ! pgrep -x OpenPnP >/dev/null 2>&1; then printf "\033[31mERROR: OpenPnP is not running.\033[0m\n"; exit 1; fi
endef

.PHONY: apply
apply: ## apply chezmoi source to ~/.openpnp2 (OpenPnP must be closed)
	$(check_openpnp_not_running)
	chezmoi apply --force $(OPENPNP_HOME)/
	@echo "\033[32mApplied chezmoi → ~/.openpnp2\033[0m"

.PHONY: pull
pull: ## pull live ~/.openpnp2 config back into chezmoi source (OpenPnP must be closed)
	$(check_openpnp_not_running)
	@for f in $(MANAGED_FILES); do \
		if [ -f "$(OPENPNP_HOME)/$$f" ]; then \
			cp "$(OPENPNP_HOME)/$$f" "$(CHEZMOI_SRC)/$$f"; \
			echo "  $$f synced"; \
		fi; \
	done
	@echo "\033[32mPulled ~/.openpnp2 → chezmoi source\033[0m"

.PHONY: diff
diff: ## show diff between chezmoi source and live config
	chezmoi diff $(OPENPNP_HOME)/ 2>/dev/null | head -100

.PHONY: status
status: ## show OpenPnP process status and config sync state
	@pgrep -f '[Oo]pen[Pp]np' >/dev/null 2>&1 && printf "OpenPnP: \033[33mRUNNING\033[0m\n" || printf "OpenPnP: \033[32mSTOPPED\033[0m\n"
	@chezmoi status $(OPENPNP_HOME)/ 2>/dev/null || true

.PHONY: feeders
feeders: ## list all feeders with positions
	@python3 -c "\
	import xml.etree.ElementTree as ET; \
	tree = ET.parse('$(OPENPNP_HOME)/machine.xml'); \
	[print(f'{\"✓\" if float(f.find(\"reference-hole-location\").get(\"x\",\"0\") if f.find(\"reference-hole-location\") is not None else \"0\") != 0 or float(f.find(\"hole-1-location\").get(\"x\",\"0\") if f.find(\"hole-1-location\") is not None else \"0\") != 0 else \" \"} {f.get(\"name\",\"\"):10s} part={f.get(\"part-id\",\"\"):25s} {f.get(\"class\",\"\").split(\".\")[-1]}') \
	for f in tree.iter('feeder') if f.get('name','').startswith(('LV','RV','LH','RH','DV'))]"

.PHONY: commit
commit: pull ## pull and commit current config state
	$(check_openpnp_not_running)
	cd $(CHEZMOI_SRC)/.. && git add dot_openpnp2/ && git commit -m "openpnp2: update config" || echo "Nothing to commit"

help: ## show this help for targets
	@grep -E --no-filename '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
