import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smart_clinic_booking/features/content/presentation/controllers/content_controller.dart';
import 'package:smart_clinic_booking/features/content/domain/entities/content_entities.dart';

class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pricingAsync = ref.watch(pricingProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Bảng giá dịch vụ', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: pricingAsync.when(
        data: (pricing) {
          final categories = pricing.map((p) => p.category).toSet().toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final items = pricing.where((p) => p.category == cat).toList();
              return _buildCategorySection(cat, items, currencyFormatter);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildCategorySection(String category, List<ServicePrice> items, NumberFormat formatter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(category, 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
        ),
        ...items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (item.description != null)
                      Text(item.description!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text(formatter.format(item.price), 
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
        )).toList(),
      ],
    );
  }
}

class SurveyScreen extends ConsumerWidget {
  const SurveyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveysAsync = ref.watch(surveyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Khảo sát sức khỏe', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: surveysAsync.when(
        data: (surveys) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: surveys.length,
          itemBuilder: (context, index) => _buildSurveyCard(context, ref, surveys[index]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }

  Widget _buildSurveyCard(BuildContext context, WidgetRef ref, Survey survey) {
    int totalVotes = survey.results.values.fold(0, (sum, val) => sum + val);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(survey.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(survey.description, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 20),
          ...survey.options.map((opt) {
            final votes = survey.results[opt.id] ?? 0;
            final percent = totalVotes > 0 ? (votes / totalVotes) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => ref.read(surveyProvider.notifier).vote(survey.id, opt.id),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(opt.text)),
                        Text('${(percent * 100).toStringAsFixed(1)}%'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent,
                        backgroundColor: Colors.grey.withOpacity(0.1),
                        color: Colors.blue,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Liên hệ góp ý', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Gửi tin nhắn cho chúng tôi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Mọi ý kiến đóng góp của bạn đều giúp ICare hoàn thiện hơn.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email liên hệ',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || !val.contains('@')) ? 'Email không hợp lệ' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Nội dung góp ý',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => (val == null || val.isEmpty) ? 'Vui lòng nhập nội dung' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Gửi góp ý'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final result = await ref.read(contactFormSubmitProvider)(_emailController.text, _messageController.text);
    setState(() => _isSubmitting = false);

    result.fold(
      (l) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: ${l.message}'))),
      (r) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gửi thành công! Cám ơn góp ý của bạn.')));
        Navigator.pop(context);
      },
    );
  }
}
