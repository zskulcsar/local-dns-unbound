# Ansible Development Guide

This document describes the Ansible project layout and how to develop and test roles with Molecule.

## Project Layout

- `ansible/roles/<role_name>/tasks/`: role tasks and task includes (for example OS/version split files)
- `ansible/roles/<role_name>/defaults/`: default variables for the role
- `ansible/roles/<role_name>/handlers/`: service restart/reload handlers
- `ansible/roles/<role_name>/templates/`: Jinja templates rendered by the role
- `ansible/roles/<role_name>/molecule/<scenario>/`: Molecule scenario for role testing

For roles that need per-platform behavior, prefer splitting tasks into files such as:

- `tasks/<os>.yml` for shared logic on that OS family
- `tasks/<os>_<version>.yml` for version-specific behavior
- `tasks/assert.yml` for reusable verification/assertion steps
- keep `tasks/main.yml` as a dispatcher

## Tooling and Dependencies

Ansible tooling is managed in `ansible/pyproject.toml` and installed with `uv`.
Containerized Molecule scenarios require either Podman or Docker.

Current default runtime in this repository is Podman.

From repository root:

```bash
make uv-sync-ansible
```

or directly:

```bash
cd ansible
uv sync --dev
```

## Running Molecule Tests

Default variables for make-based Molecule commands:

- `MOLECULE_ROLE=unbound`
- `MOLECULE_SCENARIO=default`

Default role test flow:

```bash
make molecule-test MOLECULE_ROLE=<role_name> MOLECULE_SCENARIO=default
```

Converge only:

```bash
make molecule-converge MOLECULE_ROLE=<role_name> MOLECULE_SCENARIO=default
```

Destroy test resources:

```bash
make molecule-destroy MOLECULE_ROLE=<role_name> MOLECULE_SCENARIO=default
```

Role-specific convenience targets can also exist, for example:

```bash
make molecule-test-unbound
```

You can also run Molecule directly through `uv`:

```bash
cd ansible/roles/<role_name>
uv run --project ../.. molecule test -s default
```

## Driver Selection

Current default driver is Podman in each scenario's `molecule.yml`.

To test with Docker instead, update the scenario driver setting:

```yaml
driver:
  name: docker
```

Then run the same Molecule commands.

## Multi-Platform Scenarios

Roles can define multiple platforms in a single scenario (for example multiple Ubuntu versions). Molecule executes converge/verify across all listed platforms.

Example (current `unbound` default scenario):

- Ubuntu 22.04 LTS
- Ubuntu 24.04 LTS
- Ubuntu 25.10 (interim)

## Systemd-in-Container Notes

Some roles manage system services and require systemd inside test containers. In those scenarios:

- use a systemd-capable container command (for example `/lib/systemd/systemd`)
- mount cgroups
- run containers with privileges required by the selected runtime

If service assertions fail, inspect container runtime settings first.

## Practical Test Workflow

1. Sync tools: `make uv-sync-ansible`
2. Converge role only: `make molecule-converge MOLECULE_ROLE=<role_name> MOLECULE_SCENARIO=default`
3. Verify role behavior: `make molecule-test MOLECULE_ROLE=<role_name> MOLECULE_SCENARIO=default`
4. If a run is interrupted, clean up: `make molecule-destroy MOLECULE_ROLE=<role_name> MOLECULE_SCENARIO=default`
