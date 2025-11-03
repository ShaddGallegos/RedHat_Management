# Maintenance Scripts

These scripts are used by `project_maintenance_menu.sh` for project maintenance tasks.

## Scripts

### check_role_completeness.sh
**Purpose:** Verify all Ansible role files are present 
**Called by:** Menu option 2 
**Usage:** Automatically called by maintenance menu

### setup_missing_role_files.sh
**Purpose:** Create missing Ansible role files 
**Called by:** Menu option 3 
**Usage:** Automatically called by maintenance menu

### consolidate_scripts.sh
**Purpose:** Consolidate redundant shell scripts 
**Called by:** Menu option 6 
**Usage:** Automatically called by maintenance menu

### reorganize_playbooks.sh
**Purpose:** Move playbooks to playbooks/ directory 
**Called by:** Menu option 5 
**Usage:** Automatically called by maintenance menu

## Usage

These scripts are called automatically by the maintenance menu:

```bash
./project_maintenance_menu.sh
```

Do not run these scripts directly unless you know what you're doing.

## Notes

- Scripts are called with correct paths by maintenance menu
- All operations include automatic backups
- Check `backups/` directory if you need to restore files
