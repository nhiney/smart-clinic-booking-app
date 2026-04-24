import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActionItemData {
  final String label;
  final String? assetPath;
  final String? imageUrl;
  final IconData? icon;
  final VoidCallback onTap;
  final String category;

  ActionItemData({
    required this.label,
    this.assetPath,
    this.imageUrl,
    this.icon,
    required this.onTap,
    this.category = 'all',
  });
}

class QuickActionsGrid extends StatefulWidget {
  final String userRole;
  final VoidCallback onBookAppointment;
  final VoidCallback onViewAppointments;
  final VoidCallback onMedicalRecords;
  final VoidCallback onPrescriptions;
  final VoidCallback onContactSupport;
  final VoidCallback onVoiceAssistant;
  final VoidCallback onInpatientAdmission;
  final VoidCallback onNotificationSettings;
  final VoidCallback onPricing;
  final VoidCallback onSurveys;
  final VoidCallback onProfile;

  const QuickActionsGrid({
    super.key,
    required this.userRole,
    required this.onBookAppointment,
    required this.onViewAppointments,
    required this.onMedicalRecords,
    required this.onPrescriptions,
    required this.onContactSupport,
    required this.onVoiceAssistant,
    required this.onInpatientAdmission,
    required this.onNotificationSettings,
    required this.onPricing,
    required this.onSurveys,
    required this.onProfile,
  });

  @override
  State<QuickActionsGrid> createState() => _QuickActionsGridState();
}

class _QuickActionsGridState extends State<QuickActionsGrid> {
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<ActionItemData> get _allActions => [
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/book_appointment.png',
          label: 'Đặt khám',
          onTap: widget.onBookAppointment,
          category: 'medical',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/appointment_history.png',
          label: 'Lịch sử đặt\nkhám',
          onTap: widget.onViewAppointments,
          category: 'medical',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/fee_payment.png',
          label: 'Thanh toán\nviện phí',
          onTap: widget.onPricing,
          category: 'payment',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/invoice.png',
          label: 'Hoá đơn',
          onTap: widget.onPrescriptions,
          category: 'payment',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/medical_records.png',
          label: 'Hồ sơ sức\nkhoẻ',
          onTap: widget.onMedicalRecords,
          category: 'medical',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/lab_results.png',
          label: 'Kết quả cận\nlâm sàng',
          onTap: widget.onSurveys,
          category: 'medical',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/inpatient_admission.png',
          label: 'Đăng ký\nnhập viện',
          onTap: widget.onInpatientAdmission,
          category: 'medical',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/customer_support.png',
          label: 'Lắng nghe\nkhách hàng',
          onTap: widget.onContactSupport,
          category: 'support',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/user_guide.png',
          label: 'Hướng dẫn',
          onTap: () => GoRouter.of(context).push('/under-development?title=${Uri.encodeComponent('Hướng dẫn')}'),
          category: 'support',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/home_monitoring.png',
          label: 'Theo dõi sức\nkhoẻ tại nhà',
          onTap: () => GoRouter.of(context).push('/under-development?title=${Uri.encodeComponent('Theo dõi sức khoẻ tại nhà')}'),
          category: 'medical',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/vaccination.png',
          label: 'Tiêm chủng',
          onTap: () => GoRouter.of(context).push('/under-development?title=${Uri.encodeComponent('Tiêm chủng')}'),
          category: 'medical',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/chatbot.png',
          label: 'Hỏi - đáp\n(Chatbot)',
          onTap: widget.onVoiceAssistant,
          category: 'support',
        ),
      ];

  List<ActionItemData> get _filteredActions {
    if (_searchQuery.isEmpty) return _allActions;
    return _allActions
        .where((action) => action.label.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lọc chức năng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D62A2)),
              ),
              const SizedBox(height: 20),
              _buildFilterOption('Tất cả', Icons.all_inclusive_rounded, true),
              _buildFilterOption('Y tế', Icons.medical_services_rounded, false),
              _buildFilterOption('Thanh toán', Icons.payment_rounded, false),
              _buildFilterOption('Hỗ trợ', Icons.help_outline_rounded, false),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, IconData icon, bool selected) {
    return ListTile(
      leading: Icon(icon, color: selected ? const Color(0xFF0D62A2) : Colors.grey),
      title: Text(label, style: TextStyle(color: selected ? const Color(0xFF0D62A2) : Colors.black87)),
      trailing: selected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF0D62A2)) : null,
      onTap: () {
        // Implement real filtering if needed
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        children: [
          // Header: Chức năng + Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!_isSearching)
                const Text(
                  'Chức năng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D62A2),
                  ),
                )
              else
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Tìm chức năng...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    InkWell(
                      onTap: _showFilterBottomSheet,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.tune_rounded, color: Color(0xFF0D62A2), size: 18),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 1,
                      height: 16,
                      color: Colors.grey.shade300,
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isSearching = !_isSearching;
                          if (!_isSearching) {
                            _searchQuery = '';
                            _searchController.clear();
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          _isSearching ? Icons.close_rounded : Icons.search_rounded,
                          color: const Color(0xFF0D62A2),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 4-column Grid
          if (_filteredActions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy chức năng phù hợp',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: _filteredActions.length,
              itemBuilder: (context, index) {
                final action = _filteredActions[index];
                return _ActionItem(
                  assetPath: action.assetPath,
                  imageUrl: action.imageUrl,
                  icon: action.icon,
                  label: action.label,
                  onTap: action.onTap,
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData? icon;
  final String? imageUrl;
  final String? assetPath;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    this.icon,
    this.imageUrl,
    this.assetPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFFF0F7FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D62A2).withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF0D62A2).withValues(alpha: 0.08),
                width: 1,
              ),
            ),
            child: Center(
              child: _buildIcon(),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.1,
                fontWeight: FontWeight.w600,
                color: Color(0xFF263238),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        width: 38,
        height: 38,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.medical_services_rounded,
          color: Color(0xFF0D62A2),
          size: 26,
        ),
      );
    }
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        width: 38,
        height: 38,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.medical_services_rounded,
          color: Color(0xFF0D62A2),
          size: 26,
        ),
      );
    }
    return Icon(
      icon,
      color: const Color(0xFF0D62A2),
      size: 28,
    );
  }
}
