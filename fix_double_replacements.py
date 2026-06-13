import os

fixes = [
    ("features/clinical/clinical/consultation/", "features/clinical/consultation/"),
    ("features/clinical/clinical/medical_record/", "features/clinical/medical_record/"),
    ("features/clinical/clinical/lab/", "features/clinical/lab/"),
    ("features/clinical/clinical/medication/", "features/clinical/medication/"),
    ("features/clinical/clinical/admission/", "features/clinical/admission/"),
    ("features/clinical/clinical/clinical/", "features/clinical/clinical/"),
    
    ("features/booking_system/booking_system/booking/", "features/booking_system/booking/"),
    ("features/booking_system/booking_system/appointment/", "features/booking_system/appointment/"),
    ("features/booking_system/booking_system/checkin/", "features/booking_system/checkin/"),
    
    ("features/support_services/support_services/support/", "features/support_services/support/"),
    ("features/support_services/support_services/notification/", "features/support_services/notification/"),
    ("features/support_services/support_services/sos/", "features/support_services/sos/"),
    ("features/support_services/support_services/review/", "features/support_services/review/"),
    ("features/support_services/support_services/ai/", "features/support_services/ai/"),
    
    ("features/discovery/discovery/home/", "features/discovery/home/"),
    ("features/discovery/discovery/maps/", "features/discovery/maps/"),
    ("features/discovery/discovery/content/", "features/discovery/content/"),
    
    ("features/finance/finance/payment/", "features/finance/payment/"),
    ("features/finance/finance/invoice/", "features/finance/invoice/"),
    ("features/finance/finance/insurance/", "features/finance/insurance/"),
    
    ("features/identity/identity/auth/", "features/identity/auth/"),
    ("features/identity/identity/kyc/", "features/identity/kyc/"),
    ("features/identity/identity/profile/", "features/identity/profile/"),
    ("features/identity/identity/family/", "features/identity/family/"),
    
    ("features/roles/roles/doctor/", "features/roles/doctor/"),
    ("features/roles/roles/admin/", "features/roles/admin/"),
]

for d in ['lib', 'test', 'integration_test']:
    if not os.path.exists(d): continue
    for root, dirs, files in os.walk(d):
        for f in files:
            if f.endswith('.dart'):
                path = os.path.join(root, f)
                with open(path, 'r', encoding='utf-8') as file:
                    content = file.read()
                old = content
                
                # repeat in case of triple replacements
                for _ in range(3):
                    for wrong, right in fixes:
                        content = content.replace(wrong, right)
                        
                if old != content:
                    with open(path, 'w', encoding='utf-8') as file:
                        file.write(content)
                        
print("Fixed double replacements.")
