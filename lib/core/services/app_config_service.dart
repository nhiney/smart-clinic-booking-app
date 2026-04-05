import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../config/app_config.dart';
import '../config/privacy_policy.dart';

@lazySingleton
class AppConfigService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Current Configuration (Cached)
  late AppConfig _config;
  late PrivacyPolicy _privacyPolicy;

  AppConfig get config => _config;
  PrivacyPolicy get privacyPolicy => _privacyPolicy;

  /// Initialize the configuration (Fetch from Firestore)
  /// This should be called early in the app lifecycle (e.g., in main.dart)
  Future<void> initialize() async {
    try {
      debugPrint('[CONFIG] Fetching global settings from Firestore...');
      
      // Fetch the global_settings document from app_configs collection
      final doc = await _firestore
          .collection('app_configs')
          .doc('global_settings')
          .get();

      if (doc.exists && doc.data() != null) {
        debugPrint('[CONFIG] Global settings found: ${doc.data()}');
        _config = AppConfig(doc.data()!);
      } else {
        debugPrint('[CONFIG] Global settings NOT FOUND. Using hardcoded defaults.');
        _config = AppConfig({}); // Uses defaults in AppConfig
      }

      // 2. Fetch the current privacy policy version
      await _fetchPrivacyPolicy();
      
    } catch (e) {
      debugPrint('[CONFIG] ERROR fetching settings (Falling back to defaults): $e');
      _config = AppConfig({}); // Fallback to hardcoded defaults
      _privacyPolicy = PrivacyPolicy.fallback();
    }
  }

  /// Internal helper to fetch the privacy policy based on currentPolicyId
  Future<void> _fetchPrivacyPolicy() async {
    try {
      final policyId = _config.currentPolicyId;
      debugPrint('[CONFIG] Fetching Privacy Policy version: $policyId');

      final policyDoc = await _firestore
          .collection('privacy_policies')
          .doc(policyId)
          .get();

      if (policyDoc.exists && policyDoc.data() != null) {
        debugPrint('[CONFIG] Privacy Policy $policyId found.');
        _privacyPolicy = PrivacyPolicy.fromMap(policyDoc.data()!, policyId);
      } else {
        debugPrint('[CONFIG] Privacy Policy $policyId NOT FOUND. Using fallback.');
        _privacyPolicy = PrivacyPolicy.fallback();
      }
    } catch (e) {
      debugPrint('[CONFIG] ERROR fetching Privacy Policy: $e');
      _privacyPolicy = PrivacyPolicy.fallback();
    }
  }

  /// Reload the configuration (Optional: Force refresh)
  Future<void> reload() async {
    await initialize();
  }
}
