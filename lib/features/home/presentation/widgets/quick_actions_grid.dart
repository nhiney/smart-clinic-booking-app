import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../core/extensions/context_extension.dart';

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
          label: 'Lịch sử khám',
          onTap: widget.onViewAppointments,
          category: 'medical',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/fee_payment.png',
          label: 'Viện phí',
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
          label: 'Hồ sơ',
          onTap: widget.onMedicalRecords,
          category: 'medical',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/lab_results.png',
          label: 'Kết quả CLS',
          onTap: widget.onSurveys,
          category: 'medical',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/inpatient_admission.png',
          label: 'Nhập viện',
          onTap: widget.onInpatientAdmission,
          category: 'medical',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/customer_support.png',
          label: 'Góp ý',
          onTap: widget.onContactSupport,
          category: 'support',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/chatbot.png',
          label: 'Chatbot AI',
          onTap: widget.onVoiceAssistant,
          category: 'support',
        ),
        ActionItemData(
          assetPath: 'assets/icons/quick_actions/vaccination.png',
          label: 'Tiêm chủng',
          onTap: () => context.push('/under-development?title=${Uri.encodeComponent('Tiêm chủng')}'),
          category: 'medical',
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: context.colors.surface,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lọc chức năng',
                style: context.textStyles.bodyBold.copyWith(fontSize: 20, color: context.colors.primaryDark),
              ),
              const SizedBox(height: 20),
              _buildFilterOption(context, 'Tất cả', Icons.all_inclusive_rounded, true),
              _buildFilterOption(context, 'Y tế', Icons.medical_services_rounded, false),
              _buildFilterOption(context, 'Thanh toán', Icons.payment_rounded, false),
              _buildFilterOption(context, 'Hỗ trợ', Icons.help_outline_rounded, false),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(BuildContext context, String label, IconData icon, bool selected) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? context.colors.primary.withOpacity(0.1) : context.colors.background,
          borderRadius: context.radius.sRadius,
        ),
        child: Icon(icon, color: selected ? context.colors.primary : context.colors.textHint, size: 20),
      ),
      title: Text(label, style: context.textStyles.body.copyWith(
        color: selected ? context.colors.primary : context.colors.textPrimary,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      )),
      trailing: selected ? Icon(Icons.check_circle_rounded, color: context.colors.primary, size: 20) : null,
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!_isSearching)
                Text(
                  'Dịch vụ thông minh',
                  style: context.textStyles.bodyBold.copyWith(
                    fontSize: 18,
                    color: context.colors.primaryDark,
                  ),
                )
              else
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: context.textStyles.body,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm dịch vụ...',
                      border: InputBorder.none,
                      hintStyle: context.textStyles.body.copyWith(color: context.colors.textHint),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
              Row(
                children: [
                  _buildHeaderAction(
                    icon: _isSearching ? Icons.close_rounded : Icons.search_rounded,
                    onTap: () {
                      setState(() {
                        _isSearching = !_isSearching;
                        if (!_isSearching) {
                          _searchQuery = '';
                          _searchController.clear();
                        }
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderAction(
                    icon: Icons.tune_rounded,
                    onTap: _showFilterBottomSheet,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_filteredActions.isEmpty)
            _buildEmptyResults(context)
          else
            GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 24,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
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

  Widget _buildHeaderAction({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: context.radius.sRadius,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: context.radius.sRadius,
          border: Border.all(color: context.colors.divider),
        ),
        child: Icon(icon, color: context.colors.primary, size: 20),
      ),
    );
  }

  Widget _buildEmptyResults(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48, color: context.colors.textHint.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy dịch vụ phù hợp',
            style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
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
      borderRadius: context.radius.mRadius,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.colors.surface,
                  context.colors.background,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: context.radius.mRadius,
              boxShadow: [
                BoxShadow(
                  color: context.colors.primary.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: context.colors.primary.withOpacity(0.05),
                width: 1.5,
              ),
            ),
            child: Center(
              child: _buildIcon(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall.copyWith(
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.medical_services_rounded,
          color: context.colors.primary,
          size: 28,
        ),
      );
    }
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.medical_services_rounded,
          color: context.colors.primary,
          size: 28,
        ),
      );
    }
    return Icon(
      icon,
      color: context.colors.primary,
      size: 32,
    );
  }
}
