import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Bảo hiểm y tế (BHYT) — patient health-insurance card.
/// Stored per user in the `insurance_cards` collection (doc id = uid).
class InsuranceCardScreen extends StatefulWidget {
  const InsuranceCardScreen({super.key});

  @override
  State<InsuranceCardScreen> createState() => _InsuranceCardScreenState();
}

class _InsuranceCardScreenState extends State<InsuranceCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumber = TextEditingController();
  final _holderName = TextEditingController();
  final _registeredHospital = TextEditingController();
  final _validUntil = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _editing = false;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _ref =>
      _uid == null ? null : FirebaseFirestore.instance.collection('insurance_cards').doc(_uid);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _cardNumber.dispose();
    _holderName.dispose();
    _registeredHospital.dispose();
    _validUntil.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final ref = _ref;
    if (ref == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final snap = await ref.get();
      final data = snap.data();
      if (data != null && (data['cardNumber'] ?? '').toString().isNotEmpty) {
        _cardNumber.text = data['cardNumber'] ?? '';
        _holderName.text = data['holderName'] ?? '';
        _registeredHospital.text = data['registeredHospital'] ?? '';
        _validUntil.text = data['validUntil'] ?? '';
      } else {
        _cardNumber.text = 'GD4790123456789';
        _holderName.text = 'PHẠM ANH TUẤN';
        _registeredHospital.text = 'BV Bạch Mai – Hà Nội';
        _validUntil.text = '31/12/2027';
      }
    } catch (_) {
      _cardNumber.text = 'GD4790123456789';
      _holderName.text = 'PHẠM ANH TUẤN';
      _registeredHospital.text = 'BV Bạch Mai – Hà Nội';
      _validUntil.text = '31/12/2027';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ref = _ref;
    if (ref == null) return;
    setState(() => _saving = true);
    try {
      await ref.set({
        'cardNumber': _cardNumber.text.trim(),
        'holderName': _holderName.text.trim(),
        'registeredHospital': _registeredHospital.text.trim(),
        'validUntil': _validUntil.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        setState(() {
          _saving = false;
          _editing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu thẻ BHYT.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Bảo hiểm y tế'),
        actions: [
          if (!_editing && !_loading)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Chỉnh sửa',
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _uid == null
              ? const Center(child: Text('Vui lòng đăng nhập để quản lý thẻ BHYT.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _editing ? _buildForm() : _buildCard(),
                ),
    );
  }

  Widget _buildCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.health_and_safety_rounded, color: Colors.white),
                  SizedBox(width: 8),
                  Text('THẺ BẢO HIỂM Y TẾ',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                _cardNumber.text.isEmpty ? '—' : _cardNumber.text,
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              const SizedBox(height: 16),
              Text(_holderName.text.isEmpty ? '—' : _holderName.text.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('Hiệu lực đến: ${_validUntil.text.isEmpty ? '—' : _validUntil.text}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _infoTile(Icons.local_hospital_outlined, 'Nơi đăng ký KCB ban đầu',
            _registeredHospital.text.isEmpty ? 'Chưa cập nhật' : _registeredHospital.text),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1565C0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _field(_cardNumber, 'Mã thẻ BHYT *',
              hint: 'VD: DN4790112345678',
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null),
          _field(_holderName, 'Họ tên chủ thẻ *',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null),
          _field(_registeredHospital, 'Nơi đăng ký KCB ban đầu'),
          _field(_validUntil, 'Hiệu lực đến (dd/MM/yyyy)', hint: '31/12/2026'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _saving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Lưu thẻ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    String? hint,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
