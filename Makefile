ENGINE ?= podman
TAG ?= 2.20.0
IMAGE := alpine/ansible:$(TAG)
KEYFILE ?= id_ed25519

ifeq ($(ENGINE),podman)
RUN_IMAGE := docker.io/$(IMAGE)
else
RUN_IMAGE := $(IMAGE)
endif

# Horrible, horrible stuff ...
ANS_CONTAINER=$(ENGINE) run --rm \
	--userns=keep-id \
	-v ~/.ssh/$(KEYFILE):/.ssh/$(KEYFILE):ro \
	-e HOME='/tmp' \
	-e ANSIBLE_CONFIG=/ldu/ansible/ansible.cfg \
	-e ANSIBLE_SSH_COMMON_ARGS='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -v' \
	-v $(CURDIR):/ldu $(RUN_IMAGE)

.PHONY: setup-core ansible-version
setup-core:
	./scripts/setup-core.sh $(ENGINE) $(IMAGE)

ansible-version:
	$(ENGINE) run --rm $(RUN_IMAGE) ansible --version

ansible-ping:
	$(ANS_CONTAINER) ansible main -m ping -i /ldu/ansible/inventory.ini

ansible-inv-verify:
	$(ENGINE) run --rm -v $(CURDIR):/ldu $(RUN_IMAGE) \
	ansible-inventory -i /ldu/ansible/inventory.ini --list

