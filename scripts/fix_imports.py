import os
import re

def fix_imports():
    pattern = re.compile(r"((?:import|export)\s+['\"])([^'\"]+)(['\"])")
    
    directories = ['lib', 'test', 'integration_test']
    
    for d in directories:
        if not os.path.exists(d):
            continue
        for root, dirs, files in os.walk(d):
            for file in files:
                if file.endswith('.dart'):
                    filepath = os.path.join(root, file).replace('\\', '/')
                    
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                        
                    def replacer(match):
                        prefix = match.group(1)
                        import_path = match.group(2)
                        suffix = match.group(3)
                        
                        if import_path.startswith('dart:') or import_path.startswith('package:'):
                            return match.group(0)
                            
                        # It's a relative path
                        resolved = os.path.normpath(os.path.join(os.path.dirname(filepath), import_path)).replace('\\', '/')
                        
                        if not os.path.exists(resolved):
                            # It's broken.
                            parts = import_path.split('/')
                            clean_parts = [p for p in parts if p not in ('.', '..')]
                            clean_path = '/'.join(clean_parts)
                            
                            possible_paths = []
                            for r_dir in directories:
                                if not os.path.exists(r_dir): continue
                                for r, d_names, fs in os.walk(r_dir):
                                    for fs_file in fs:
                                        if fs_file == clean_parts[-1]:
                                            p = os.path.join(r, fs_file).replace('\\', '/')
                                            if p.endswith(clean_path):
                                                possible_paths.append(p)
                                            
                            if len(possible_paths) == 1:
                                p = possible_paths[0]
                                if p.startswith('lib/'):
                                    pkg_path = p.replace('lib/', 'package:smart_clinic_booking/')
                                    return f"{prefix}{pkg_path}{suffix}"
                                else:
                                    # For test files importing other test files, keep relative or make absolute
                                    # Since test files can't be imported via package: unless they are in lib.
                                    # We will just compute the correct relative path.
                                    new_rel = os.path.relpath(p, os.path.dirname(filepath)).replace('\\', '/')
                                    if not new_rel.startswith('.'):
                                        new_rel = './' + new_rel
                                    return f"{prefix}{new_rel}{suffix}"
                        return match.group(0)
                        
                    new_content = pattern.sub(replacer, content)
                    if new_content != content:
                        with open(filepath, 'w', encoding='utf-8') as f:
                            f.write(new_content)

fix_imports()
print("Fixed.")
