# Integration Tests

End-to-end integration tests using Ansible playbooks.

## Running Tests

```bash
# Run all integration tests
ansible-playbook tests/integration/test_*.yml -i tests/fixtures/inventory

# Run specific test
ansible-playbook tests/integration/test_lvm_workflow.yml -i tests/fixtures/inventory

# Check mode (dry-run)
ansible-playbook tests/integration/test_lvm_workflow.yml -i tests/fixtures/inventory --check
```

## Test Inventory

Use fixtures inventory for testing:
```bash
-i tests/fixtures/inventory
```

## Writing Tests

Create playbooks with `test_` prefix that verify complete workflows.
