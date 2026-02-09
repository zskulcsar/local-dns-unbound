ENGINE ?= podman
TAG ?= 2.20.0
IMAGE := alpine/ansible:$(TAG)
KEYFILE ?= id_ed25519

ifeq ($(ENGINE),podman)
RUN_IMAGE := docker.io/$(IMAGE)
else
RUN_IMAGE := $(IMAGE)
endif

.PHONY: help \
	setup-core ansible-version ansible-ping ansible-inv-verify \
	uv-sync-ansible molecule-test molecule-converge molecule-destroy \
	molecule-test-unbound molecule-converge-unbound molecule-destroy-unbound

MOLECULE_ROLE ?= unbound
MOLECULE_SCENARIO ?= default

## Default
help: ## List available make targets with descriptions.
	@printf "Available targets:\n"
	@grep -hE '.*##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*##"} {printf "  %-20s %s\n", $$1, $$2}'


# Horrible, horrible stuff ...
ANS_CONTAINER=$(ENGINE) run --rm \
	--userns=keep-id \
	-v ~/.ssh/$(KEYFILE):/.ssh/$(KEYFILE):ro \
	-e HOME='/tmp' \
	-e ANSIBLE_CONFIG=/ldu/ansible/ansible.cfg \
	-e ANSIBLE_SSH_COMMON_ARGS='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -v' \
	-v $(CURDIR):/ldu $(RUN_IMAGE)

## Setup and verifications
setup-core: ## Setup core dependencies
	./scripts/setup-core.sh $(ENGINE) $(IMAGE)

ansible-version: ## Check ansible version in the container image
	$(ENGINE) run --rm $(RUN_IMAGE) ansible --version

ansible-ping: ## Ping the hosts from the inventory - use for checking connectivity
	$(ANS_CONTAINER) ansible main -m ping -i /ldu/ansible/inventory.ini

ansible-inv-verify: ## Verify the inventory file
	$(ENGINE) run --rm -v $(CURDIR):/ldu $(RUN_IMAGE) \
	ansible-inventory -i /ldu/ansible/inventory.ini --list

uv-sync-ansible: ## Install/update Ansible tooling dependencies with uv (ansible scoped)
	cd ansible && uv sync --dev

molecule-test: ## Run Molecule full test for a role (MOLECULE_ROLE=..., MOLECULE_SCENARIO=...)
	cd ansible/roles/$(MOLECULE_ROLE) && uv run --project ../.. molecule test -s $(MOLECULE_SCENARIO)

molecule-converge: ## Run Molecule converge for a role (MOLECULE_ROLE=..., MOLECULE_SCENARIO=...)
	cd ansible/roles/$(MOLECULE_ROLE) && uv run --project ../.. molecule converge -s $(MOLECULE_SCENARIO)

molecule-destroy: ## Destroy Molecule resources for a role (MOLECULE_ROLE=..., MOLECULE_SCENARIO=...)
	cd ansible/roles/$(MOLECULE_ROLE) && uv run --project ../.. molecule destroy -s $(MOLECULE_SCENARIO)

molecule-test-unbound: ## Run Molecule full test for unbound role
	$(MAKE) molecule-test MOLECULE_ROLE=unbound MOLECULE_SCENARIO=default

molecule-converge-unbound: ## Run Molecule converge for unbound role
	$(MAKE) molecule-converge MOLECULE_ROLE=unbound MOLECULE_SCENARIO=default

molecule-destroy-unbound: ## Destroy Molecule resources for unbound role
	$(MAKE) molecule-destroy MOLECULE_ROLE=unbound MOLECULE_SCENARIO=default
