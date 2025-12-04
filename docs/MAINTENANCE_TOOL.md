# Maintenance Tool Guide

## Overview

The `maintenance.py` script is a Python-based interactive tool for managing the LVM Auto-Extension project.

## Quick Start

```bash
./maintenance.py
```

## Main Menu

```text
╔═════════════════════════════════════════╗
║ LVM Auto-Extension Maintenance Tool ║
╚═════════════════════════════════════════╝

1) Setup & Initialization
2) Consolidation
3) Analysis & Reporting
4) Cleanup & Maintenance
8) Cleanup base scripts
9) Quick start
0) Exit
```

## Menu Details

### 1. Setup & Initialization

#### 1.1 Initial Project Setup
**Purpose:** First-time project setup 
**What it does:**
- Creates `inventory/` structure
- Generates `inventory/hosts` file
- Creates `group_vars/all.yml`
- Creates `.env.example`
- Validates all roles
- Offers to create missing roles

**When to use:** First time setting up project

**Example:**
```bash
./maintenance.py
Choice: 1
Choice: 1
# Follow prompts
```

#### 1.2 Check Roles
**Purpose:** Verify role completeness 
**What it checks:**
- [OK] Role directory exists
- [OK] `tasks/main.yml` present
- [OK] `defaults/main.yml` present
- [OK] `meta/main.yml` present

**Output Example:**
```
[OK] servicenow_ticket_management
 [OK] tasks/main.yml
 [OK] defaults/main.yml
 [OK] meta/main.yml
[ERROR] lvm_extension_orchestrator (not found)
```

#### 1.3 Create Missing Roles
**Purpose:** Generate missing role structures 
**Creates:**
- Directory structure (tasks/, defaults/, meta/, etc.)
- `tasks/main.yml` with default tasks
- `defaults/main.yml` with variables
- `meta/main.yml` with metadata
- `README.md` with documentation

**Use case:** When roles are missing or corrupted

#### 1.4 Recreate All Roles
**Purpose:** Rebuild all role structures 
**Warning:** [WARNING] Backs up but recreates all roles 
**Use case:** Major role corruption or restructuring

### 2. Consolidation

#### 2.1 Reorganize Playbooks
**Purpose:** Move playbooks to `playbooks/` directory 
**Actions:**
- Scans root for `*.yml` files
- Excludes `site.yml` and `requirements.yml`
- Moves to `playbooks/`
- Creates backup

**Before:**
```
Add_LVM_to_System_nutanix/
├── disk_usage_monitor.yml
├── extend_lvm.yml
└── respond_to_disk_alert.yml
```

**After:**
```
Add_LVM_to_System_nutanix/
└── playbooks/
 ├── disk_usage_monitor.yml
 ├── extend_lvm.yml
 └── respond_to_disk_alert.yml
```

#### 2.2 Organize Scripts
**Purpose:** Create script directory structure 
**Creates:**
- `scripts/operations/` (for operational scripts)
- `scripts/maintenance/` (for maintenance scripts)

#### 2.3 Organize Tests
**Purpose:** Create test directory structure 
**Creates:**
- `tests/unit/` (unit tests)
- `tests/integration/` (integration tests)
- `tests/molecule/` (molecule tests)
- `tests/fixtures/` (test fixtures)

#### 2.4 Full Consolidation
**Purpose:** Run all consolidation tasks 
**Runs:** Options 2.1, 2.2, and 2.3 sequentially

### 3. Analysis & Reporting

#### 3.1 Analyze Obsolete Files
**Purpose:** Find files that can be cleaned 
**Searches for:**
- `*.backup` files
- `*.bak` files
- `*~` editor backups
- `*.swp` vim swap files
- `__pycache__/` directories

**Output:** `obsolete_analysis_YYYYMMDD_HHMMSS.txt`

#### 3.2 Analyze YAML Files
**Purpose:** Verify essential playbooks and roles 
**Checks:**
- Essential playbooks exist
- Playbook locations (playbooks/ or root)
- Role completeness

**Output Example:**
```
━━━ Essential Playbooks ━━━
[OK] extend_lvm.yml (playbooks/)
[OK] disk_usage_monitor.yml (playbooks/)
[ERROR] rulebook.yml (missing)

━━━ Roles ━━━
[OK] servicenow_ticket_management
[WARNING] lvm_extension_orchestrator
```

#### 3.3 Generate Report
**Purpose:** Create comprehensive project analysis 
**Includes:**
- File counts (YAML, Shell, Python)
- Role inventory
- Playbook inventory
- Project structure

**Output:** `project_analysis_YYYYMMDD_HHMMSS.txt`

### 4. Cleanup & Maintenance

#### 4.1 Clean Obsolete Files
**Purpose:** Remove backup and temporary files 
**[WARNING] Warning:** Deletes files (but creates backup first) 
**Removes:**
- `*.backup`, `*.bak`, `*~`
- `*.pyc`, `*.swp`
- `__pycache__/` directories

**Safety:** Creates backup before deletion

#### 4.2 Clean Reports
**Purpose:** Delete old analysis reports 
**Finds:** `*_analysis_*.txt` files 
**Action:** Lists and offers batch deletion 
**Safety:** Requires confirmation

#### 4.3 View Structure
**Purpose:** Display project directory tree 
**Method:** Uses `tree` command if available, else Python fallback 
**Depth:** Shows 3 levels deep 
**Excludes:** `.git`, `__pycache__`, `backups`

**Example Output:**
```
Add_LVM_to_System_nutanix/
├── inventory/
│ ├── hosts
│ └── group_vars/
│ └── all.yml
├── playbooks/
│ ├── disk_usage_monitor.yml
│ └── extend_lvm.yml
└── roles/
 ├── lvm_smart_extend/
 └── servicenow_ticket_management/
```

#### 4.4 View Backups
**Purpose:** List recent automatic backups 
**Shows:** Last 10 backups with:
- Backup name
- Size in MB
- Modification date/time

**Example Output:**
```
Last 10:
• playbook_reorg_20241003_143022
 2.45MB | 2024-10-03 14:30
• cleanup_20241003_120015
 0.12MB | 2024-10-03 12:00
```

### 8. Cleanup Base Scripts
**Purpose:** Remove old shell scripts from project root 
**[WARNING] Warning:** Deletes all `*.sh` files from base directory 
**Safety:** Creates backup before deletion 
**Use case:** After consolidating to Python maintenance tool

### 9. Quick Start Guide
**Purpose:** Display quick reference 
**Shows:**
- Setup steps
- Common commands
- Running examples

## Backup System

### Automatic Backups

All destructive operations create automatic backups:

```
backups/
├── cleanup_20241003_143022/
├── playbook_reorg_20241003_120015/
├── roles_recreate_20241002_093045/
└── script_cleanup_20241001_160022/
```

### Backup Naming

Format: `<operation>_YYYYMMDD_HHMMSS/`

Examples:
- `cleanup_20241003_143022` - Cleanup operation on Oct 3, 2024 at 14:30:22
- `playbook_reorg_20241003_120015` - Playbook reorganization on Oct 3, 2024 at 12:00:15

### Restoring from Backup

```bash
# List backups
ls -lah backups/

# Restore specific backup
cp -r backups/playbook_reorg_20241003_143022/*.

# Or use maintenance tool
./maintenance.py
Choice: 4 → 4 # View backups
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | Error |
| 130 | Interrupted by user (Ctrl+C) |

## Tips & Best Practices

### First Time Users
1. Run option `1 → 1` (Initial setup)
2. Check roles with `1 → 2`
3. Create missing roles with `1 → 3`
4. View structure with `4 → 3`

### Regular Maintenance
1. Check for obsolete files: `3 → 1`
2. Clean obsolete files: `4 → 1`
3. Generate periodic reports: `3 → 3`

### Before Major Changes
1. Generate report: `3 → 3`
2. View backups: `4 → 4`
3. Proceed with changes

### After File Reorganization
1. Full consolidation: `2 → 4`
2. Verify structure: `4 → 3`
3. Clean obsolete: `4 → 1`

## Keyboard Shortcuts

- `Ctrl+C` - Interrupt/Cancel (safe exit)
- `Enter` - Continue at pause prompts
- `0` - Back to previous menu
- `q` or `0` from main menu - Exit

## Color Legend

| Color | Meaning |
|-------|---------|
| Green | Success, present, complete |
| Red | Error, missing, failed |
| Yellow | Warning, action needed |
| Blue | Information |
| Magenta | Menu headers |
| Cyan | Section headers |

## Troubleshooting

### "Permission Denied"
```bash
chmod +x maintenance.py
```

### "Module not found"
```bash
# Ensure Python 3.9+
python3 --version

# Check Python path
which python3
```

### "No such file or directory"
```bash
# Ensure you're in project root
cd /path/to/Add_LVM_to_System_nutanix
pwd
```

### Stuck at Menu
- Press `0` to go back
- Press `Ctrl+C` to exit
- Close terminal and restart

## Advanced Usage

### Running Specific Functions

```python
# Import and use directly
from maintenance import ProjectMaintenance

pm = ProjectMaintenance()
pm.check_roles()
pm.create_missing()
```

### Batch Operations

```bash
# Create wrapper script
cat > batch_maintenance.sh << 'EOF'
#!/bin/bash
python3 << 'PYTHON'
from maintenance import ProjectMaintenance
pm = ProjectMaintenance()
pm.initial_setup()
pm.check_roles()
pm.create_missing()
PYTHON
EOF

chmod +x batch_maintenance.sh
./batch_maintenance.sh
```

## Support

If you encounter issues:
1. Check this guide
2. Run option `9` (Quick start)
3. View logs in `backups/` directory
4. Create GitHub issue
5. Contact: sysadmin@example.com