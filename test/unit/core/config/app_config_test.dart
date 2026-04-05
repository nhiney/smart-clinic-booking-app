import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clinic_booking/core/config/app_config.dart';

void main() {
  group('AppConfig Verification', () {
    test('should use default values when map is empty', () {
      final config = AppConfig({});
      
      expect(config.privacyPolicyUrl, 'https://pub-bc3669a9821248918f203546714adf67.r2.dev/consent/PRIVACY_POLICY.pdf');
      expect(config.isMaintenanceMode, false);
      expect(config.apiBaseUrl, '');
    });

    test('should use Firestore values when provided', () {
      final firestoreData = {
        'privacyPolicyUrl': 'https://new-url.com/policy.pdf',
        'isMaintenanceMode': true,
        'apiBaseUrl': 'https://api.icare.vn',
      };
      
      final config = AppConfig(firestoreData);
      
      expect(config.privacyPolicyUrl, 'https://new-url.com/policy.pdf');
      expect(config.isMaintenanceMode, true);
      expect(config.apiBaseUrl, 'https://api.icare.vn');
    });

    test('should handle missing fields individually', () {
      final firestoreData = {
        'apiBaseUrl': 'https://api.icare.vn',
        // privacyPolicyUrl is missing
      };
      
      final config = AppConfig(firestoreData);
      
      // Should use default for missing field
      expect(config.privacyPolicyUrl, 'https://pub-bc3669a9821248918f203546714adf67.r2.dev/consent/PRIVACY_POLICY.pdf');
      // Should use value from map if it exists
      expect(config.apiBaseUrl, 'https://api.icare.vn');
    });
    
    test('should handle incorrect types by falling back to default', () {
      final firestoreData = {
        'privacyPolicyUrl': 12345, // Wrong type (int instead of String)
        'isMaintenanceMode': "true", // Wrong type (String instead of bool)
      };
      
      final config = AppConfig(firestoreData);
      
      expect(config.privacyPolicyUrl, 'https://pub-bc3669a9821248918f203546714adf67.r2.dev/consent/PRIVACY_POLICY.pdf');
      expect(config.isMaintenanceMode, false);
    });

    test('should return correct currentPolicyId', () {
      final config = AppConfig({'currentPolicyId': 'v1.2'});
      expect(config.currentPolicyId, 'v1.2');
    });

    test('should default currentPolicyId to stable', () {
      final config = AppConfig({});
      expect(config.currentPolicyId, 'stable');
    });
  });
}
