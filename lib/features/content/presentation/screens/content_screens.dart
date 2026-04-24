import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_clinic_booking/core/theme/colors/app_colors.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/features/content/presentation/controllers/content_controller.dart';
import 'package:smart_clinic_booking/features/content/domain/entities/content_entities.dart';
import 'package:smart_clinic_booking/features/content/presentation/screens/survey_form_screen.dart';

class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  static const _kPrimary = Color(0xFF0D62A2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricingAsync = ref.watch(pricingProvider);
    final fmt = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: const BrandedAppBar(title: 'Bảng giá dịch vụ', showBackButton: true),
      body: pricingAsync.when(
        data: (pricing) {
          if (pricing.isEmpty) {
            return const Center(child: Text('Chưa có dữ liệu bảng giá.'));
          }
          final categories = pricing.map((p) => p.category).toSet().toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final items = pricing.where((p) => p.category == cat).toList();
              return _CategorySection(category: cat, items: items, formatter: fmt);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final String category;
  final List<ServicePrice> items;
  final NumberFormat formatter;
  const _CategorySection({required this.category, required this.items, required this.formatter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0D62A2).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              category,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0D62A2)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                if (item.description != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(item.description!, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              formatter.format(item.price),
                              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0D62A2), fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < items.length - 1) const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SurveyScreen extends ConsumerStatefulWidget {
  const SurveyScreen({super.key});

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  String _activeCategory = 'Tất cả';

  static const _categories = [
    'Tất cả',
    'Dịch vụ',
    'Bác sĩ',
    'Cơ sở vật chất',
    'Trải nghiệm',
    'Dinh dưỡng',
  ];

  @override
  Widget build(BuildContext context) {
    final surveysAsync = ref.watch(surveyProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BrandedAppBar(title: 'Khảo sát & Đánh giá', showBackButton: true),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 52,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isActive = cat == _activeCategory;
                return GestureDetector(
                  onTap: () => setState(() => _activeCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive ? AppColors.primary : Colors.grey.shade300,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Survey list
          Expanded(
            child: surveysAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Lỗi tải khảo sát: $e'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.read(surveyProvider.notifier).loadSurveys(),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
              data: (surveys) {
                final filtered = _activeCategory == 'Tất cả'
                    ? surveys
                    : surveys.where((s) => s.category == _activeCategory).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.poll_outlined, size: 60, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 12),
                        Text('Chưa có khảo sát nào', style: TextStyle(color: Color(0xFF94A3B8))),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _SurveyCard(survey: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SurveyCard extends StatelessWidget {
  final Survey survey;
  const _SurveyCard({required this.survey});

  static (Color, Color, IconData) _categoryStyle(String? category) {
    switch (category) {
      case 'Dịch vụ':
        return (const Color(0xFF2563EB), const Color(0xFFDBEAFE), Icons.medical_services_outlined);
      case 'Bác sĩ':
        return (const Color(0xFF059669), const Color(0xFFD1FAE5), Icons.person_outlined);
      case 'Cơ sở vật chất':
        return (const Color(0xFFD97706), const Color(0xFFFEF3C7), Icons.apartment_outlined);
      case 'Trải nghiệm':
        return (const Color(0xFF7C3AED), const Color(0xFFEDE9FE), Icons.star_outline_rounded);
      case 'Dinh dưỡng':
        return (const Color(0xFFDB2777), const Color(0xFFFCE7F3), Icons.restaurant_outlined);
      default:
        return (AppColors.primary, const Color(0xFFDBEAFE), Icons.poll_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (fgColor, bgColor, icon) = _categoryStyle(survey.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (survey.category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            survey.category!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: fgColor,
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(
                        survey.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        survey.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: fgColor, size: 20),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Bottom section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${survey.estimatedMinutes} phút',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.help_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${survey.questions.length} câu',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                if (survey.responseCount > 0) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${survey.responseCount} lượt',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurveyFormScreen(survey: survey),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Làm khảo sát →',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

class ContactFormScreen extends ConsumerStatefulWidget {
  const ContactFormScreen({super.key});

  @override
  ConsumerState<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends ConsumerState<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: const BrandedAppBar(title: 'Liên hệ & Góp ý', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D62A2), Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.support_agent_rounded, color: Colors.white, size: 40),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Chúng tôi luôn lắng nghe', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('Mọi góp ý đều giúp ICare tốt hơn mỗi ngày.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _contactField(
                controller: _nameController,
                label: 'Họ và tên',
                icon: Icons.person_outline_rounded,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 14),
              _contactField(
                controller: _emailController,
                label: 'Email liên hệ',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
              ),
              const SizedBox(height: 14),
              _contactField(
                controller: _subjectController,
                label: 'Tiêu đề',
                icon: Icons.subject_rounded,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 14),
              _contactField(
                controller: _messageController,
                label: 'Nội dung góp ý',
                icon: Icons.message_outlined,
                maxLines: 5,
                validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập nội dung' : null,
              ),
              const SizedBox(height: 24),
              // Hotline info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
                ),
                child: const Column(
                  children: [
                    _ContactInfoRow(Icons.phone_rounded, 'Hotline', '1800 1234 (Miễn phí)'),
                    Divider(height: 16),
                    _ContactInfoRow(Icons.access_time_rounded, 'Giờ làm việc', 'T2 - T7: 7:00 - 17:00'),
                    Divider(height: 16),
                    _ContactInfoRow(Icons.location_on_outlined, 'Địa chỉ', '123 Đường Sức Khoẻ, TP.HCM'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submit,
                  icon: _isSubmitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(_isSubmitting ? 'Đang gửi...' : 'Gửi góp ý'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D62A2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0D62A2), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final result = await ref.read(contactFormSubmitProvider)(_emailController.text, _messageController.text);
    setState(() => _isSubmitting = false);
    if (!mounted) return;
    result.fold(
      (l) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${l.message}'))),
      (r) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gửi thành công! Cám ơn góp ý của bạn.'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      },
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ContactInfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0D62A2)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
