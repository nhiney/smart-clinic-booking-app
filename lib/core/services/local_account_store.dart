import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Quản lý danh sách tài khoản bệnh nhân đã đăng ký.
/// Dùng SharedPreferences — hoạt động hoàn toàn offline,
/// không phụ thuộc Firebase Auth hay Firestore.
class LocalAccountStore {
  static const String _accountsKey = 'icare_patient_accounts_v1';

  static LocalAccountStore? _instance;
  static LocalAccountStore get instance => _instance ??= LocalAccountStore._();
  LocalAccountStore._();

  /// Chuẩn hóa số điện thoại về dạng 84XXXXXXXXX
  static String normalizePhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('84') && clean.length >= 11) return clean;
    if (clean.startsWith('0') && clean.length == 10) return '84${clean.substring(1)}';
    if (clean.length == 9) return '84$clean';
    return clean;
  }

  /// Đọc toàn bộ accounts: { normalizedPhone -> {password, name, createdAt} }
  Future<Map<String, Map<String, dynamic>>> _readAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_accountsKey);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
    } catch (e) {
      debugPrint('[LocalAccountStore] Read error: $e');
      return {};
    }
  }

  Future<void> _writeAll(Map<String, Map<String, dynamic>> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accountsKey, jsonEncode(data));
    } catch (e) {
      debugPrint('[LocalAccountStore] Write error: $e');
    }
  }

  /// Lưu tài khoản mới sau khi đăng ký thành công.
  /// Trả về false nếu số điện thoại đã tồn tại.
  Future<bool> saveAccount({
    required String phone,
    required String password,
    String? name,
  }) async {
    final normalized = normalizePhone(phone);
    final accounts = await _readAll();

    if (accounts.containsKey(normalized)) {
      debugPrint('[LocalAccountStore] Phone $normalized already registered.');
      return false;
    }

    accounts[normalized] = {
      'password': password,
      'name': name ?? 'Bệnh nhân',
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _writeAll(accounts);
    debugPrint('[LocalAccountStore] Saved account: $normalized');
    return true;
  }

  /// Kiểm tra số điện thoại đã đăng ký chưa.
  Future<bool> isPhoneRegistered(String phone) async {
    final normalized = normalizePhone(phone);
    final accounts = await _readAll();
    final exists = accounts.containsKey(normalized);
    debugPrint('[LocalAccountStore] isPhoneRegistered($normalized) = $exists');
    return exists;
  }

  /// Xác thực đăng nhập: phone + password đúng thì trả về thông tin account.
  Future<Map<String, dynamic>?> verifyLogin({
    required String phone,
    required String password,
  }) async {
    final normalized = normalizePhone(phone);
    final accounts = await _readAll();

    final account = accounts[normalized];
    if (account == null) {
      debugPrint('[LocalAccountStore] Phone not found: $normalized');
      return null;
    }

    final savedPassword = (account['password'] as String? ?? '').trim();
    final inputPassword = password.trim();

    if (savedPassword == inputPassword) {
      debugPrint('[LocalAccountStore] Login OK: $normalized');
      return {...account, 'phone': normalized};
    }

    debugPrint('[LocalAccountStore] Wrong password for $normalized');
    return null;
  }

  /// Lấy thông tin account theo số điện thoại.
  Future<Map<String, dynamic>?> getAccount(String phone) async {
    final normalized = normalizePhone(phone);
    final accounts = await _readAll();
    final account = accounts[normalized];
    if (account != null) return {...account, 'phone': normalized};
    return null;
  }

  /// Debug: lấy danh sách tất cả tài khoản. Chỉ dùng trong kDebugMode.
  Future<Map<String, Map<String, dynamic>>> getAllAccounts() async {
    return _readAll();
  }

  /// Xóa toàn bộ dữ liệu (dùng cho test).
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accountsKey);
  }
}
