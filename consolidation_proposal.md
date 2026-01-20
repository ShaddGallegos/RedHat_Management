Consolidation proposal — Platform & Product roles

Goal: merge duplicated/fragmented roles into a clear, discoverable top-level `roles/` layout so each role name tells you what it is and where it belongs.

Naming convention (proposal):
- Use snake_case, prefix with product/platform and purpose: `<product>_<purpose>` or `<platform>_<version>_<purpose>` when version/OS specificity matters.
- Place product-specific implementations under `roles/` (not `redhat_products/`) once merged, keeping `redhat_products/` as a reference archive if needed.

High-level groups and proposed canonical targets (examples & mappings):

1) Ansible Automation Platform (AAP)
- Canonical: `roles/aap` (core installation/config) and supporting roles `roles/aap_controller`, `roles/aap_deploy`, `roles/aap_inventories`, `roles/aap_projects`, `roles/aap_templates`
- Current candidates to merge:
  - `aap_2_6_setup` -> `aap` (merge tasks into `roles/aap/install.yml` / `roles/aap/tasks`)
  - `aap_controller_setup` -> `aap_controller`
  - `aap_deployment` -> `aap_deploy`
  - `aap_credentials_config` -> `aap/credentials` or `aap_credentials`
  - `aap_inventories_config` -> `aap_inventories`
  - `aap_projects_config` -> `aap_projects`
  - `aap_templates_config` -> `aap_templates`
  - `ansible_automation_platform` (composite) -> keep as `roles/aap` with imported task files (`install.yml`, `configure.yml`, `test.yml`, `backup.yml`, `restore.yml`)

2) EDA (Event-Driven Ansible)
- Canonical: `roles/eda` and `roles/eda_start`, `roles/eda_stop`, `roles/eda_config` as needed
- Current candidates: `eda_configuration`, `start_eda`, `stop_eda`, `aap_eda` (under redhat_products) -> merge into `roles/eda` and subroles or task files

3) CMDB (already merged)
- `roles/cmdb` is canonical (merged result stored in `roles/cmdb/setup/merged_main.yml`). Keep support references updated.

4) Satellite & Red Hat product roles
- Canonical base names: `satellite_618_install`, `satellite_618_configure`, `satellite_618_kickstart`, `satellite_content`, `satellite_reporting`, etc.
- Sources to merge:
  - `redhat_products/satellite/*` -> consolidate into `roles/satellite_*` where appropriate. Many already exist: `satellite_618_install`, `satellite_618_configure_*` — unify duplicates and remove `contrib/*` duplicates.

5) IDM
- Canonical: `roles/idm` or `roles/idm_412_integration` for versioned integration
- Map `idm_412_integration` and `redhat_products/idm/*` -> `roles/idm*` and move specific integrations into `roles/idm/integration` or `roles/idm_replica` as subroles.

6) Infrastructure / hypervisors
- Libvirt: canonical `roles/libvirt` (or `libvirt_115_rhel_10` if OS/version matters)
  - Merge: `libvirt_115_rhel_10_configure`, `libvirt_platform`, `libvirt_setup`, `libvirt_vm_provisioner` -> `roles/libvirt_*` (subroles: `configure`, `vm_create`, `provision`)
- VMware: `roles/vmware` (merge `vmware` top-level and `infrastructure/cloud/vmware` if duplicate)
- Nutanix: `roles/nutanix` (merge `nutanix` and any duplicates)

7) Cloud providers
- AWS: `roles/aws` or `roles/aws_platform` (current `aws_platform` -> `aws_platform` retained or `aws` shortened)
- Azure: `roles/azure_platform` (already present)
- GCP: find `google`/`gcp` entries and consolidate into `roles/gcp` or `roles/google_cloud`
- Keep provider-specific inventories under `roles/<provider>/inventory` as present.

8) OS and common
- Keep `roles/os/*` as the canonical OS role set (rhel_base, ssh_hardening, firewall_base, etc.). Merge any duplicated OS tasks from product roles into these shared OS roles.

9) OpenShift
- Canonical: `roles/openshift` and versioned roles like `openshift_4_21_deployment` -> move product-specific playbooks into `roles/openshift` with versioned task files or subroles.

10) Windows
- Canonical: `roles/windows` (merge `windows` and any windows-specific tasks/collection content)

11) ansibledev / tooling
- `ansibledev_node` and other dev helper roles -> `roles/ansibledev` or `roles/ansibledev_node` to keep developer utilities clearly separated.

12) Support / Integrations
- `roles/support/*` keep wrappers but update to call canonical roles in `roles/` instead of `support/ansible_cmdb_setup` etc.

Suggested merge process (per group):
1. Create backup (already done for CMDB); continue to make per-group tarball backups before changes.
2. Create a branch `feature/consolidate-<group>` for each group (e.g., `feature/consolidate-aap`).
3. Produce a mapping preview file listing: source path -> target path, conflict notes, variable name differences.
4. Copy content into `roles/<target>` under logical subfolders (`tasks/install.yml`, `tasks/configure.yml`, `handlers/`, `templates/`, `defaults/`).
5. Reconcile `defaults/main.yml` (normalize variable names; add mapping in `defaults/` for backward compatibility, e.g., `legacy_ansible_cmdb_output_dir: ...` pointing to new `cmdb_output_dir`).
6. Update all references across repo (`git grep` and replace role names in `playbooks/`, `roles/support/`, `docs/`, `integration/`).
7. Run `ansible-playbook --syntax-check` and `ansible-lint` on wrapper playbooks and key playbooks.
8. Commit and open PR for review, preserving history where possible (if `git mv` is used, history will move; if copying, preserve source backup).

Next actions I will take (if you confirm):
- Generate a detailed mapping file for the AAP group (exact source -> destination entries) and a proposed plan of the specific file moves. I'll stage a preview patch (no deletions yet) so you can review before I remove source directories.

Do you want me to start with the AAP group mapping now? (I will create `/consolidation_proposal-aap.md` with exact mappings.)
