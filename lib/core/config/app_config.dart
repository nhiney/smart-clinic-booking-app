class AppConfig {
  final Map<String, dynamic> _settings;

  AppConfig(this._settings);

  /// Helper to get a typed value or a default
  T _get<T>(String key, T defaultValue) {
    if (_settings.containsKey(key) && _settings[key] is T) {
      return _settings[key] as T;
    }
    return defaultValue;
  }

  // Specific Typed Getters (Professionally Structured)
  
  /// Legal & Privacy Policy URL
  String get privacyPolicyUrl => _get<String>(
        'privacyPolicyUrl',
        'https://pub-bc3669a9821248918f203546714adf67.r2.dev/consent/PRIVACY_POLICY.pdf',
      );

  /// API Base URL (Example of future expansion)
  String get apiBaseUrl => _get<String>('apiBaseUrl', '');

  /// Maintenance Mode flag
  bool get isMaintenanceMode => _get<bool>('isMaintenanceMode', false);

  /// Default Privacy Policy Version ID
  String get currentPolicyId => _get<String>('currentPolicyId', 'stable');

  /// Feature Flags
  bool get useMockData => _get<bool>('useMockData', false);

  /// Firestore Collections Configuration
  String get healthSummaryCollection => _get<String>('healthSummaryCollection', 'health_summary');
  String get medicationsCollection => _get<String>('medicationsCollection', 'medications');
  String get newsCollection => _get<String>('newsCollection', 'health_news');

  /// Generic access for unknown configuration keys
  dynamic operator [](String key) => _settings[key];

  @override
  String toString() => 'AppConfig($_settings)';
}
