# Unit Tests

Unit tests for individual components and functions.

## Structure

- `test_*.py` - Python unit tests
- `test_*.sh` - Shell script tests

## Running Tests

```bash
# All Python tests
pytest tests/unit/

# Specific test
pytest tests/unit/test_lvm_extend.py

# With coverage
pytest tests/unit/ --cov=roles

# Verbose output
pytest tests/unit/ -vv
```

## Writing Tests

Create test files matching the pattern `test_*.py` or `test_*.sh`.

Example:
```python
def test_example():
 assert True
```
