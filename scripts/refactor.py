import os
import re

mapping = {
    "auth": "identity/auth",
    "kyc": "identity/kyc",
    "profile": "identity/profile",
    "family": "identity/family",
    "appointment": "booking_system/appointment",
    "booking": "booking_system/booking",
    "checkin": "booking_system/checkin",
    "clinical": "clinical/clinical",
    "consultation": "clinical/consultation",
    "medical_record": "clinical/medical_record",
    "lab": "clinical/lab",
    "medication": "clinical/medication",
    "admission": "clinical/admission",
    "payment": "finance/payment",
    "invoice": "finance/invoice",
    "insurance": "finance/insurance",
    "home": "discovery/home",
    "maps": "discovery/maps",
    "content": "discovery/content",
    "ai": "support_services/ai",
    "support": "support_services/support",
    "notification": "support_services/notification",
    "sos": "support_services/sos",
    "review": "support_services/review",
    "doctor": "roles/doctor",
    "admin": "roles/admin"
}

# Reverse mapping: new domain/feature -> old feature
reverse_mapping = {v: k for k, v in mapping.items()}

def get_old_path(new_path):
    parts = new_path.split('/')
    if len(parts) >= 4 and (parts[0] == 'lib' or parts[0] == 'integration_test') and parts[1] == 'features':
        domain_feature = parts[2] + '/' + parts[3]
        if domain_feature in reverse_mapping:
            old_feature = reverse_mapping[domain_feature]
            return '/'.join([parts[0], 'features', old_feature] + parts[4:])
    return new_path

def get_new_path(old_path):
    parts = old_path.split('/')
    if len(parts) >= 3 and (parts[0] == 'lib' or parts[0] == 'integration_test') and parts[1] == 'features':
        feature = parts[2]
        if feature in mapping:
            new_domain_feature = mapping[feature].split('/')
            return '/'.join([parts[0], 'features', new_domain_feature[0], new_domain_feature[1]] + parts[3:])
    return old_path

def fix_imports_in_file(filepath):
    # Read file
    with open(filepath, 'r', encoding='utf-8') as f:
        original_content = f.read()
        
    content = original_content

    # 1. Fix absolute imports
    for old_feat, new_feat in mapping.items():
        content = content.replace(f"package:smart_clinic_booking/features/{old_feat}/", f"package:smart_clinic_booking/features/{new_feat}/")

    # 2. Fix relative imports
    normalized_filepath = filepath.replace('\\', '/')
    old_file_path = get_old_path(normalized_filepath)
    
    pattern = re.compile(r"((?:import|export)\s+['\"])([^'\"]+)(['\"])")
    
    def replacer(match):
        prefix = match.group(1)
        import_path = match.group(2)
        suffix = match.group(3)
        
        # Ignore package: and dart:
        if import_path.startswith('dart:') or import_path.startswith('package:'):
            return match.group(0)
            
        old_dir = os.path.dirname(old_file_path)
        import posixpath
        imported_old_path = posixpath.normpath(posixpath.join(old_dir, import_path))
        
        imported_new_path = get_new_path(imported_old_path)
        
        new_dir = posixpath.dirname(normalized_filepath)
        new_rel = posixpath.relpath(imported_new_path, new_dir)
        
        if not new_rel.startswith('.'):
            new_rel = './' + new_rel
            
        return f"{prefix}{new_rel}{suffix}"

    new_content = pattern.sub(replacer, content)
    
    if new_content != original_content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)

for directory in ['lib', 'test', 'integration_test']:
    if os.path.exists(directory):
        for root, dirs, files in os.walk(directory):
            for file in files:
                if file.endswith('.dart'):
                    fix_imports_in_file(os.path.join(root, file).replace('\\', '/'))

print("Refactoring complete.")
