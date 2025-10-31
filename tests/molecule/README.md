# Molecule Tests

Role-level testing using Molecule framework.

## Prerequisites

```bash
pip install molecule molecule-docker ansible-lint
```

## Running Tests

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
```

## Molecule Commands

- `molecule create` - Create test instance
- `molecule converge` - Run playbook
- `molecule verify` - Run verification
- `molecule test` - Full test sequence
- `molecule destroy` - Cleanup

## Structure

Each role has its own molecule directory:
```
tests/molecule/
├── lvm_smart_extend/
│ ├── molecule.yml
│ ├── converge.yml
│ └── verify.yml
└──...
```
