#!/bin/bash
# filepath: /home/sgallego/Downloads/GIT/infra-automation/plugins/inventory/
set -e
cd /home/sgallego/Downloads/GIT

# 1) Rename project folder (git mv) - run this if your repo root is Add_LVM_to_System_nutanix parent
git mv Add_LVM_to_System_nutanix infra-automation || { echo "git mv failed or already renamed"; }

cd infra-automation

# 2) Rename main script to use underscore (importable)
git mv aap_lvm_manager.py infra_automation.py || mv aap_lvm_manager.py infra_automation.py

# 3) Update run_aap.py to reference new script name (safe fallback using runpy)
# (create a backup)
cp run_aap.py run_aap.py.bak
python3 - <<'PY'
from pathlib import Path
p = Path("run_aap.py")
text = p.read_text()
text = text.replace('aap_lvm_manager.py', 'infra_automation.py')
text = text.replace('from aap_lvm_manager import MenuSystem', '# import attempt removed: use runpy fallback')
p.write_text(text)
print("run_aap.py updated")
PY

# 4) Search/replace other references to aap_lvm_manager -> infra_automation where appropriate
# (print files to review)
echo "Files referencing 'aap_lvm_manager':"
grep -R --line-number "aap_lvm_manager" || true

# 5) Commit and push changes
git add -A
git commit -m "Rename project to infra-automation and main script to infra_automation.py"
BR=$(git rev-parse --abbrev-ref HEAD)
git push origin "$BR"
echo "Pushed to remote branch: $BR"

echo "Done. Run the tool with: python3 run_aap.py"