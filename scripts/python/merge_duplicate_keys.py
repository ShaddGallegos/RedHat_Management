#!/usr/bin/env python3
from pathlib import Path
import re

TARGET = Path('/home/sgallego/Downloads/RedHat_Management/roles/rhel_stig/tasks')
KEYS_TO_MERGE = {'when', 'tags'}

KEY_LINE_RE = re.compile(r'^(?P<indent>\s{2})(?P<key>[a-zA-Z_][a-zA-Z0-9_\-]*):\s*(?P<rest>.*)$')

def merge_task_lines(lines):
    # lines: list of task lines (including '- name:' first line)
    out = []
    collected = {}  # key -> list of rest strings
    other_lines = []
    for ln in lines:
        m = KEY_LINE_RE.match(ln)
        if m and m.group('key') in KEYS_TO_MERGE:
            k = m.group('key')
            val = m.group('rest').strip()
            collected.setdefault(k, []).append(val)
        else:
            other_lines.append(ln)
    # rebuild: insert merged keys after the first line (- name:)
    if not other_lines:
        return lines
    out.append(other_lines[0])
    # find insertion index after initial one-line header
    idx = 1
    # copy non-merge key lines that come before next merge-key occurrences
    for ln in other_lines[1:]:
        m = KEY_LINE_RE.match(ln)
        if m and m.group('key') in KEYS_TO_MERGE:
            continue
        out.append(ln)
    # append merged keys
    for k, vals in collected.items():
        if not vals:
            continue
        # if single val and looks like list or yaml, keep as-is
        if len(vals) == 1 and (vals[0].startswith('[') or vals[0].startswith('{') or vals[0].startswith('|')):
            out.append(f'  {k}: {vals[0]}')
        else:
            out.append(f'  {k}:')
            for v in vals:
                v_str = v
                # clean trailing comments
                out.append(f'    - {v_str}')
    return out

def process_file(p: Path):
    text = p.read_text()
    lines = text.splitlines()
    out_lines = []
    task_buf = []
    in_task = False
    for ln in lines:
        if ln.startswith('- name:'):
            if in_task:
                out_lines.extend(merge_task_lines(task_buf))
                task_buf = []
            in_task = True
            task_buf.append(ln)
            continue
        if in_task:
            # task continues until next top-level '- name:' or file end
            if ln.startswith('- name:'):
                # handled above
                pass
            # collect
            task_buf.append(ln)
        else:
            out_lines.append(ln)
    if in_task and task_buf:
        out_lines.extend(merge_task_lines(task_buf))

    new_text = '\n'.join(out_lines) + '\n'
    if new_text != text:
        bak = p.with_suffix(p.suffix + '.dupbak')
        if not bak.exists():
            p.rename(bak)
            p.write_text(new_text)
            print(f'Merged duplicates in {p} (backup at {bak})')
        else:
            p.write_text(new_text)
            print(f'Merged duplicates in {p} (backup existed)')
    else:
        print(f'No duplicates found in {p}')

def main():
    if not TARGET.exists():
        print('Target tasks directory not found:', TARGET)
        return
    for p in sorted(TARGET.glob('*.yml')):
        process_file(p)

if __name__ == '__main__':
    main()
