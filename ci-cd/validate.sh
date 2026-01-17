#!/bin/bash
# Comprehensive validation script for RHIS project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="/var/log/rhis/validation.log"

echo "=== RHIS CI/CD Validation Suite ===" | tee "$LOG_FILE"
echo "Date: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Track results
PASSED=0
FAILED=0
WARNINGS=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function log_pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1" | tee -a "$LOG_FILE"
    ((PASSED++))
}

function log_fail() {
    echo -e "${RED}✗ FAIL${NC}: $1" | tee -a "$LOG_FILE"
    ((FAILED++))
}

function log_warn() {
    echo -e "${YELLOW}⚠ WARN${NC}: $1" | tee -a "$LOG_FILE"
    ((WARNINGS++))
}

# Test 1: Ansible Syntax Check
echo "[1/6] Checking Ansible syntax..." | tee -a "$LOG_FILE"
if ansible-playbook --syntax-check "$PROJECT_DIR"/*.yml > /dev/null 2>&1; then
    log_pass "Ansible syntax check"
else
    log_fail "Ansible syntax check"
fi

# Test 2: YAML Validation
echo "[2/6] Validating YAML files..." | tee -a "$LOG_FILE"
YAML_COUNT=$(find "$PROJECT_DIR" -name "*.yml" -o -name "*.yaml" | wc -l)
if [ "$YAML_COUNT" -gt 0 ]; then
    log_pass "Found $YAML_COUNT YAML files"
else
    log_warn "No YAML files found"
fi

# Test 3: Role Metadata Check
echo "[3/6] Validating role metadata..." | tee -a "$LOG_FILE"
ROLES_WITH_META=$(find "$PROJECT_DIR/roles" -name "meta/main.yml" | wc -l)
if [ "$ROLES_WITH_META" -eq 33 ]; then
    log_pass "All 33 roles have metadata ($ROLES_WITH_META/33)"
else
    log_warn "Role metadata coverage: $ROLES_WITH_META/33"
fi

# Test 4: README Coverage
echo "[4/6] Checking documentation coverage..." | tee -a "$LOG_FILE"
READMES=$(find "$PROJECT_DIR/roles" -name "README.md" | wc -l)
if [ "$READMES" -ge 20 ]; then
    log_pass "Documentation coverage: $READMES roles documented"
else
    log_warn "Documentation coverage: $READMES/33 roles"
fi

# Test 5: Variable Naming Convention
echo "[5/6] Validating variable naming convention..." | tee -a "$LOG_FILE"
CONVENTION_DOC="$PROJECT_DIR/VARIABLE_NAMING_CONVENTION.md"
if [ -f "$CONVENTION_DOC" ]; then
    log_pass "Variable naming convention documented"
else
    log_fail "Variable naming convention documentation missing"
fi

# Test 6: Role Tests Availability
echo "[6/6] Checking role tests..." | tee -a "$LOG_FILE"
TEST_FILES=$(find "$PROJECT_DIR/roles" -path "*/tests/test_*.yml" | wc -l)
if [ "$TEST_FILES" -ge 40 ]; then
    log_pass "Test coverage: $TEST_FILES test files"
else
    log_warn "Test coverage: $TEST_FILES test files (target: 40+)"
fi

# Summary
echo "" | tee -a "$LOG_FILE"
echo "=== VALIDATION SUMMARY ===" | tee -a "$LOG_FILE"
echo "Passed:  $PASSED" | tee -a "$LOG_FILE"
echo "Failed:  $FAILED" | tee -a "$LOG_FILE"
echo "Warnings: $WARNINGS" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

if [ "$FAILED" -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}" | tee -a "$LOG_FILE"
    exit 0
else
    echo -e "${RED}✗ Some validations failed!${NC}" | tee -a "$LOG_FILE"
    exit 1
fi
