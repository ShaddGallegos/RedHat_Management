# CI/CD Validation Framework

This directory contains CI/CD validation scripts and configurations for RHIS project quality assurance.

## Validation Components

### 1. Syntax Validation
- Ansible playbook syntax checking
- YAML file validation
- Jinja2 template validation

### 2. Linting Checks
- Ansible-lint for best practices
- YAML linting for formatting
- Variable naming convention validation

### 3. Test Execution
- Role functional tests
- Integration tests
- Deployment scenario tests

### 4. Code Quality
- Python code linting
- Documentation consistency
- File permission validation

## Workflow

```
Code Change
    ↓
Pre-commit Hooks
    ↓
Syntax Validation
    ↓
Linting Checks
    ↓
Unit Tests
    ↓
Integration Tests
    ↓
Deployment Simulation
    ↓
Quality Report
    ↓
Merge Approval
```

## Quick Start

Run all validations:
```bash
make validate
```

Run specific checks:
```bash
make syntax-check
make lint
make test
```

## Validation Results

All validation results are logged to:
- `/var/log/rhis/validation.log` - Validation execution log
- `/var/log/rhis/validation-report.html` - HTML report
- `/var/log/rhis/validation-summary.txt` - Summary report

## Continuous Integration

Automated CI/CD pipeline runs on:
- Every commit
- Pull requests
- Scheduled daily checks
- Pre-release checks

## Support

For validation issues, see:
- VALIDATION_CHECKLIST.md - Manual validation guide
- Specific validation scripts in ./scripts/ directory
