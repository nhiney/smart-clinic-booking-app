import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _tabIndex = 0;
  String? _selectedMethod;

  final List<Map<String, dynamic>> _invoices = [
    {
      'id': 'HD001',
      'doctor': 'BS. Nguyễn Văn An',
      'specialty': 'Tim mạch',
      'date': '20/05/2026',
      'amount': 350000,
      'status': 'unpaid',
      'color': Color(0xFF1565C0),
    },
    {
      'id': 'HD002',
      'doctor': 'BS. Trần Thị Bình',
      'specialty': 'Nhi khoa',
      'date': '15/05/2026',
      'amount': 200000,
      'status': 'paid',
      'color': Color(0xFF00897B),
    },
    {
      'id': 'HD003',
      'doctor': 'BS. Lê Minh Châu',
      'specialty': 'Da liễu',
      'date': '10/04/2026',
      'amount': 280000,
      'status': 'paid',
      'color': Color(0xFF8E24AA),
    },
    {
      'id': 'HD004',
      'doctor': 'BS. Phạm Thanh Dũng',
      'specialty': 'Thần kinh',
      'date': '01/04/2026',
      'amount': 450000,
      'status': 'refunded',
      'color': Color(0xFFF57C00),
    },
  ];

  List<Map<String, dynamic>> get _filteredInvoices {
    if (_tabIndex == 0) return _invoices;
    if (_tabIndex == 1)
      return _invoices.where((i) => i['status'] == 'unpaid').toList();
    return _invoices
        .where((i) => i['status'] == 'paid' || i['status'] == 'refunded')
        .toList();
  }

  String _formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';
  }

  void _showPaymentDialog(Map<String, dynamic> invoice) {
    _selectedMethod = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thanh toán viện phí',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Số tiền: ${_formatAmount(invoice['amount'])}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Chọn phương thức thanh toán',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),

              // Phương thức thanh toán
              ...[
                    {
                      'method': 'momo',
                      'label': 'MoMo',
                      'icon': Icons.account_balance_wallet,
                      'color': Color(0xFFAE2070),
                    },
                    {
                      'method': 'vnpay',
                      'label': 'VNPay',
                      'icon': Icons.payment,
                      'color': Color(0xFF0066B3),
                    },
                    {
                      'method': 'card',
                      'label': 'Thẻ ngân hàng',
                      'icon': Icons.credit_card,
                      'color': Color(0xFF43A047),
                    },
                    {
                      'method': 'cash',
                      'label': 'Tiền mặt tại quầy',
                      'icon': Icons.money,
                      'color': Color(0xFFF57C00),
                    },
                  ]
                  .map(
                    (m) => GestureDetector(
                      onTap: () => setModalState(
                        () => _selectedMethod = m['method'] as String,
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _selectedMethod == m['method']
                              ? (m['color'] as Color).withOpacity(0.1)
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedMethod == m['method']
                                ? m['color'] as Color
                                : Colors.grey[200]!,
                            width: _selectedMethod == m['method'] ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (m['color'] as Color).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                m['icon'] as IconData,
                                color: m['color'] as Color,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              m['label'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            if (_selectedMethod == m['method'])
                              Icon(
                                Icons.check_circle,
                                color: m['color'] as Color,
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedMethod == null
                      ? null
                      : () {
                          Navigator.pop(context);
                          setState(() => invoice['status'] = 'paid');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thanh toán thành công!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    disabledBackgroundColor: Colors.grey[300],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Xác nhận thanh toán',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        title: const Text(
          'Thanh toán viện phí',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Tổng quan
          Container(
            color: const Color(0xFF1565C0),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Chưa thanh toán',
                    value: _formatAmount(
                      _invoices
                          .where((i) => i['status'] == 'unpaid')
                          .fold(0, (sum, i) => sum + (i['amount'] as int)),
                    ),
                    color: Colors.orange,
                    icon: Icons.pending_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Đã thanh toán',
                    value: _formatAmount(
                      _invoices
                          .where((i) => i['status'] == 'paid')
                          .fold(0, (sum, i) => sum + (i['amount'] as int)),
                    ),
                    color: Colors.green,
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
          ),

          // Tab bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _TabButton(
                  label: 'Tất cả',
                  isSelected: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0),
                ),
                const SizedBox(width: 8),
                _TabButton(
                  label: 'Chưa thanh toán',
                  isSelected: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1),
                ),
                const SizedBox(width: 8),
                _TabButton(
                  label: 'Đã xong',
                  isSelected: _tabIndex == 2,
                  onTap: () => setState(() => _tabIndex = 2),
                ),
              ],
            ),
          ),

          // Danh sách hóa đơn
          Expanded(
            child: _filteredInvoices.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không có hóa đơn',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final invoice = _filteredInvoices[index];
                      return _InvoiceCard(
                        invoice: invoice,
                        formatAmount: _formatAmount,
                        onPay: invoice['status'] == 'unpaid'
                            ? () => _showPaymentDialog(invoice)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1565C0)
                : const Color(0xFFF0F6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Map<String, dynamic> invoice;
  final String Function(int) formatAmount;
  final VoidCallback? onPay;

  const _InvoiceCard({
    required this.invoice,
    required this.formatAmount,
    this.onPay,
  });

  String get _statusText {
    switch (invoice['status']) {
      case 'unpaid':
        return 'Chưa thanh toán';
      case 'paid':
        return 'Đã thanh toán';
      case 'refunded':
        return 'Đã hoàn tiền';
      default:
        return '';
    }
  }

  Color get _statusColor {
    switch (invoice['status']) {
      case 'unpaid':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (invoice['color'] as Color).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: invoice['color'] as Color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice['doctor'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A237E),
                        ),
                      ),
                      Text(
                        invoice['specialty'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusText,
                    style: TextStyle(
                      fontSize: 11,
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      invoice['date'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Text(
                  formatAmount(invoice['amount']),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),

            Row(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'Mã HĐ: ${invoice['id']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),

            if (onPay != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Thanh toán ngay'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
