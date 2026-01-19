# Standard Makefile for Ansible projects

# Variables
ANSIBLE_PLAYBOOK := ansible-playbook
ANSIBLE_LINT := ansible-lint
VAULT_PASSWORD_FILE := ~/.vault_pass.txt
PROJECT_NAME := $(shell basename $(CURDIR))
ANSIBLE_ROLES_PATH := ./roles

# Default target
.PHONY: all
all: help

# Help target
.PHONY: help
help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install      Install Ansible collections and dependencies"
	@echo "  bootstrap    Bootstrap the environment"
	@echo "  setup        Setup the project environment"
	@echo "  test         Test the playbooks (syntax check)"
	@echo "  lint         Lint all Ansible files"
	@echo "  site         Deploy the complete site.yml playbook"
	@echo "  encrypt      Encrypt vault files"
	@echo "  decrypt      Decrypt vault files"
	@echo "  clean        Clean temporary files"
	@echo "  help         Show this help message"

# Install Ansible collections and dependencies
.PHONY: install
install:
	@echo "Installing Ansible collections and dependencies..."
	@if [ -f requirements.txt ]; then \
		pip install -q -r requirements.txt || true; \
	fi
	@if [ -f requirements.yml ]; then \
		ansible-galaxy collection install -r requirements.yml -p ./collections || true; \
	fi
	@echo "Installation completed."

# Bootstrap environment
.PHONY: bootstrap
bootstrap: install setup
	@echo "Bootstrap completed."

# Setup project environment
.PHONY: setup
setup:
	@echo "Setting up project environment for $(PROJECT_NAME)..."
	@if [ -f env.yml.example ] && [ ! -f env.yml ]; then \
		echo "NOTE: This project no longer creates an env.yml in the repository root."; \
		echo "Copy the example into your local vaulted config at ~/.ansible/conf/env.yml and edit it there (do NOT commit personal secrets)."; \
		echo "Example: mkdir -p ~/.ansible/conf && cp env.yml.example ~/.ansible/conf/env.yml"; \
	fi
	@if [ -f vault.yml.example ] && [ ! -f vault.yml ]; then \
		echo "Creating vault.yml from example..."; \
		cp vault.yml.example vault.yml; \
	fi
	@echo "Setup completed."

# Run the complete site playbook
.PHONY: site
site:
	@echo "Running site.yml playbook..."
	@ANSIBLE_ROLES_PATH=$(ANSIBLE_ROLES_PATH) $(ANSIBLE_PLAYBOOK) site.yml -i inventory/hosts

# Test playbooks (syntax check)
.PHONY: test
test:
	@echo "Testing playbooks..."
	@ANSIBLE_ROLES_PATH=$(ANSIBLE_ROLES_PATH) $(ANSIBLE_PLAYBOOK) site.yml --syntax-check
	@echo "Syntax check passed!"

# Lint Ansible files
.PHONY: lint
lint:
	@echo "Linting Ansible files..."
	@if command -v $(ANSIBLE_LINT) > /dev/null; then \
		$(ANSIBLE_LINT) playbooks/ roles/ 2>/dev/null || echo "Linting complete (warnings may exist)"; \
	else \
		echo "ansible-lint not installed. Install with: pip install ansible-lint"; \
	fi
.PHONY: encrypt
encrypt:
	@echo "Encrypting vault files..."
	@if [ -f vault.yml ]; then \
		ansible-vault encrypt vault.yml --vault-password-file $(VAULT_PASSWORD_FILE); \
	else \
		echo "Error: vault.yml not found"; \
		exit 1; \
	fi

# Decrypt vault files
.PHONY: decrypt
decrypt:
	@echo "Decrypting vault files..."
	@if [ -f vault.yml ]; then \
		ansible-vault decrypt vault.yml --vault-password-file $(VAULT_PASSWORD_FILE); \
	else \
		echo "Error: vault.yml not found"; \
		exit 1; \
	fi

# Clean temporary files
.PHONY: clean
clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.retry" -type f -delete
	@find . -name "*.pyc" -type f -delete
	@find . -name "__pycache__" -type d -exec rm -rf {} +
	@find . -name ".pytest_cache" -type d -exec rm -rf {} +
