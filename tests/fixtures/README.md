# Test Fixtures

Test data, mock responses, and sample configurations.

## Structure

```
fixtures/
├── inventory/ # Test inventory files
├── host_vars/ # Test host variables
├── group_vars/ # Test group variables
├── mock_responses/ # Mock API responses
└── sample_data/ # Sample disk/LVM data
```

## Usage

Reference fixtures in tests:
```yaml
- name: Test with fixture
 include_vars: tests/fixtures/sample_data/disk_info.yml
```

## Creating Fixtures

Add realistic test data that represents production scenarios.
