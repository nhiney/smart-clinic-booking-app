import 'package:flutter/material.dart';

class _C {
  static const primary = Color(0xFF1D4ED8);
  static const bg = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const green = Color(0xFF059669);
  static const amber = Color(0xFFD97706);
}

class _Service {
  final IconData icon;
  final String name;
  final int qty;
  final int price;
  const _Service(this.icon, this.name, this.qty, this.price);
}

/// Hóa đơn khám / Thanh toán — chi tiết dịch vụ, BHYT, tổng tiền + nút thanh toán.
/// Route /invoice-bill.
class InvoiceBillScreen extends StatefulWidget {
  const InvoiceBillScreen({super.key});

  @override
  State<InvoiceBillScreen> createState() => _InvoiceBillScreenState();
}

class _InvoiceBillScreenState extends State<InvoiceBillScreen> {
  bool _paid = false;
  bool _processing = false;

  static const _services = [
    _Service(Icons.medical_services_rounded, 'Phí khám tim mạch chuyên sâu', 1, 350000),
    _Service(Icons.favorite_rounded, 'Điện tâm đồ ECG', 1, 150000),
    _Service(Icons.monitor_heart_rounded, 'Siêu âm tim 2D', 1, 280000),
    _Service(Icons.science_rounded, 'Xét nghiệm máu tổng quát', 1, 180000),
  ];

  int get _subtotal => _services.fold(0, (s, e) => s + e.price * e.qty);
  int get _insurance => -320000;
  int get _discount => -50000;
  int get _total => _subtotal + _insurance + _discount;

  String _money(int v) {
    final s = v.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return '${v < 0 ? '−' : ''}${buf.toString()}đ';
  }

  Future<void> _pay() async {
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _processing = false;
      _paid = true;
    });
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle_rounded, color: _C.green, size: 48),
        title: const Text('Thanh toán thành công',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Hóa đơn ${_money(_total)} đã được thanh toán qua VNPay.',
            textAlign: TextAlign.center),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                  backgroundColor: _C.primary, foregroundColor: Colors.white),
              child: const Text('Hoàn tất'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        foregroundColor: _C.textPrimary,
        elevation: 0,
        title: const Text('Hóa đơn khám',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz_rounded)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _invoiceHeader(),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text('CHI TIẾT DỊCH VỤ',
                style: TextStyle(
                    color: _C.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5)),
          ),
          ..._services.map(_serviceRow),
          const SizedBox(height: 16),
          _totals(),
        ],
      ),
      bottomNavigationBar: _payBar(),
    );
  }

  Widget _invoiceHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HÓA ĐƠN',
                        style: TextStyle(
                            color: _C.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                    SizedBox(height: 4),
                    Text('#HD-23052026-0451',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _C.textPrimary)),
                    SizedBox(height: 4),
                    Text('Phát hành: 23/05/2026 · 10:42',
                        style: TextStyle(color: _C.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _paid
                      ? _C.green.withValues(alpha: 0.12)
                      : _C.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: _paid ? _C.green : _C.amber, size: 8),
                    const SizedBox(width: 5),
                    Text(_paid ? 'Đã thanh toán' : 'Chờ thanh toán',
                        style: TextStyle(
                            color: _paid ? _C.green : _C.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: _C.border),
          ),
          Row(
            children: [
              Expanded(child: _miniInfo('BỆNH NHÂN', 'Phạm Anh Tuấn', 'BHYT GD4-0123')),
              Expanded(child: _miniInfo('BÁC SĨ', 'BS. Trần Minh Quân', 'Tim mạch')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(String label, String name, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: _C.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(name,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _C.textPrimary)),
        Text(sub, style: const TextStyle(fontSize: 12, color: _C.textSecondary)),
      ],
    );
  }

  Widget _serviceRow(_Service s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: _C.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(s.icon, color: _C.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _C.textPrimary)),
                Text('x ${s.qty}',
                    style: const TextStyle(
                        fontSize: 12, color: _C.textSecondary)),
              ],
            ),
          ),
          Text(_money(s.price),
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary)),
        ],
      ),
    );
  }

  Widget _totals() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _C.border),
      ),
      child: Column(
        children: [
          _totalRow('Tạm tính', _money(_subtotal), _C.textPrimary),
          const SizedBox(height: 10),
          _totalRow('BHYT chi trả (80%)', _money(_insurance), _C.green),
          const SizedBox(height: 10),
          _totalRow('Giảm giá (Hạng Vàng)', _money(_discount), _C.green),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: _C.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TỔNG THANH TOÁN',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _C.textSecondary)),
              Text(_money(_total),
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: _C.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: _C.textSecondary)),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: valueColor)),
      ],
    );
  }

  Widget _payBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _paid || _processing ? null : _pay,
            style: ElevatedButton.styleFrom(
              backgroundColor: _paid ? _C.green : _C.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              disabledBackgroundColor:
                  (_paid ? _C.green : _C.primary).withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _processing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_paid ? Icons.check_rounded : Icons.lock_rounded,
                          size: 20),
                      const SizedBox(width: 8),
                      Text(
                          _paid
                              ? 'Đã thanh toán ${_money(_total)}'
                              : 'Thanh toán ${_money(_total)}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
