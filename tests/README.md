# Tests Directory

This directory contains all test files for the LVM Auto-Extension project.

## Structure

```
tests/
├── unit/ # Unit tests (Python, Shell)
├── integration/ # Integration tests (Playbooks)
├── molecule/ # Molecule tests (Role testing)
│ ├── lvm_smart_extend/
│ ├── lvm_system_inspection/
│ └──...
└── fixtures/ # Test fixtures and mock data
```

## Unit Tests

Located in `tests/unit/` - tests for individual functions and modules.

### Running Python Unit Tests

```bash
# Install test dependencies
pip install pytest pytest-ansible

# Run all unit tests
pytest tests/unit/

# Run with coverage
pytest tests/unit/ --cov=roles --cov-report=html

# Run specific test file
pytest tests/unit/test_lvm_extend.py -v
```

### Running Shell Script Tests

```bash
# Run specific shell test
bash tests/unit/test_script_functions.sh

# Or make executable and run
chmod +x tests/unit/test_*.sh
./tests/unit/test_script_functions.sh
```

## Integration Tests

Located in `tests/integration/` - end-to-end playbook tests.

### Running Integration Tests

```bash
# Run integration test playbook
ansible-playbook tests/integration/test_lvm_workflow.yml -i tests/fixtures/inventory

# With check mode
ansible-playbook tests/integration/test_lvm_workflow.yml -i tests/fixtures/inventory --check

# With verbose output
ansible-playbook tests/integration/test_lvm_workflow.yml -i tests/fixtures/inventory -vvv
```

## Molecule Tests

Located in `tests/molecule/` - role-level testing with Molecule.

### Prerequisites

```bash
# Install Molecule
pip install molecule molecule-docker ansible-lint

# Or for Podman
pip install molecule molecule-podman ansible-lint
```

### Running Molecule Tests

```bash
# Test specific role
cd tests/molecule/lvm_smart_extend
molecule test

# Test all roles
for role in tests/molecule/*; do
 cd "$role"
 molecule test
 cd -
done

# Run specific test sequence
molecule create # Create test instance
molecule converge # Run playbook
molecule verify # Run verification
molecule destroy # Cleanup
```

### Available Scenarios

Each role may have multiple test scenarios:

- **default** - Standard role functionality
- **alternative** - Alternative configurations
- **edge_cases** - Edge case handling

Example:
```bash
cd tests/molecule/lvm_smart_extend
molecule test -s default
molecule test -s edge_cases
```

## Test Fixtures

Located in `tests/fixtures/` - test data, mock responses, sample configurations.

### Available Fixtures

- `inventory/` - Test inventory files
- `host_vars/` - Test host variables
- `group_vars/` - Test group variables
- `mock_responses/` - Mock API responses
- `sample_data/` - Sample disk/LVM data

## Writing Tests

### Unit Test Example (Python)

```python
# tests/unit/test_lvm_extend.py
import pytest
from ansible.module_utils.basic import AnsibleModule

def test_calculate_extend_size():
 current_size = 100
 extend_percent = 20
 expected = 20
 
 result = calculate_extend_size(current_size, extend_percent)
 assert result == expected
```

### Integration Test Example (Playbook)

```yaml
# tests/integration/test_lvm_extension.yml
---
- name: Test LVM Extension Workflow
 hosts: localhost
 gather_facts: true
 
 tasks:
 - name: Test role inclusion
 include_role:
 name: lvm_smart_extend
 vars:
 vg_name: test_vg
 lv_name: test_lv
 mount_point: /test
 
 - name: Verify extension
 assert:
 that:
 - lv_extend_result.changed
 fail_msg: "LVM extension failed"
```

### Molecule Test Example

```yaml
# tests/molecule/lvm_smart_extend/molecule.yml
---
dependency:
 name: galaxy
driver:
 name: docker
platforms:
 - name: rhel8-instance
 image: registry.access.redhat.com/ubi8/ubi-init
 pre_build_image: true
provisioner:
 name: ansible
 playbooks:
 converge: converge.yml
 verify: verify.yml
verifier:
 name: ansible
```

## Continuous Integration

Tests are designed to run in CI/CD pipelines:

```yaml
# Example.gitlab-ci.yml
test:unit:
 script:
 - pip install pytest pytest-ansible
 - pytest tests/unit/ --junitxml=report.xml

test:integration:
 script:
 - ansible-playbook tests/integration/test_*.yml -i tests/fixtures/inventory

test:molecule:
 script:
 - molecule test --all
```

## Test Coverage

Generate test coverage reports:

```bash
# Python coverage
pytest tests/unit/ --cov=roles --cov-report=html
firefox htmlcov/index.html

# Ansible playbook coverage (using ansible-coverage)
ansible-playbook tests/integration/test_*.yml --coverage

# Role coverage with Molecule
molecule test --all -- --coverage
```

## Mocking External Services

### Mocking ServiceNow API

```python
# tests/unit/test_servicenow.py
from unittest.mock import patch, MagicMock

@patch('pysnow.Client')
def test_create_ticket(mock_client):
 mock_client.return_value.resource.return_value.create.return_value = {
 'number': 'INC0001234'
 }
 
 result = create_servicenow_ticket(...)
 assert result['number'] == 'INC0001234'
```

### Mocking Nutanix API

```python
# tests/fixtures/mock_responses/nutanix_disk_create.json
{
 "status": {
 "execution_context": {
 "task_uuid": "12345-67890-abcdef"
 }
 }
}
```

## Best Practices

1. **Test Isolation**: Each test should be independent
2. **Clean Setup/Teardown**: Always cleanup test resources
3. **Use Fixtures**: Reuse test data via fixtures
4. **Mock External APIs**: Don't make real API calls in tests
5. **Test Edge Cases**: Include error scenarios
6. **Document Tests**: Add docstrings to test functions
7. **Keep Tests Fast**: Unit tests should run in seconds
8. **Verify State**: Assert expected outcomes
9. **Use Check Mode**: Test playbooks with --check first
10. **Version Control**: Commit test files with code

## Troubleshooting

### Test Failures

```bash
# Run single test with verbose output
pytest tests/unit/test_name.py::test_function -vv

# Debug with pdb
pytest tests/unit/test_name.py --pdb

# Show print statements
pytest tests/unit/test_name.py -s
```

### Molecule Issues

```bash
# Clean up existing instances
molecule destroy

# Check syntax
molecule syntax

# Lint before testing
ansible-lint tests/molecule/*/

# Use different driver
molecule test --driver-name podman
```

### Integration Test Issues

```bash
# Test with specific inventory
ansible-playbook tests/integration/test.yml -i tests/fixtures/inventory

# Dry run
ansible-playbook tests/integration/test.yml --check --diff

# Step through tasks
ansible-playbook tests/integration/test.yml --step
```

## Contributing

When adding new features:

1. Write tests first (TDD approach)
2. Ensure all tests pass before submitting PR
3. Add integration tests for new playbooks
4. Update test documentation
5. Maintain test coverage above 80%

## Resources

- [Ansible Testing Strategies](https://docs.ansible.com/ansible/latest/dev_guide/testing.html)
- [Molecule Documentation](https://molecule.readthedocs.io/)
- [Pytest Documentation](https://docs.pytest.org/)
- [Ansible Lint](https://ansible-lint.readthedocs.io/)
