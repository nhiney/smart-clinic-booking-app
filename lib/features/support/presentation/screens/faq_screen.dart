import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/features/support/presentation/controllers/support_controller.dart';
import 'package:smart_clinic_booking/features/support/domain/entities/support_entities.dart';

class FAQScreen extends ConsumerStatefulWidget {
  const FAQScreen({super.key});

  @override
  ConsumerState<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends ConsumerState<FAQScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = ['Tất cả', 'Đặt lịch', 'Tài khoản', 'Thanh toán', 'Kỹ thuật'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(faqProvider.notifier).loadFAQs());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(faqProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const BrandedAppBar(
        title: 'Câu hỏi thường gặp',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: Skeletonizer(
              enabled: state.isLoading,
              child: state.error != null
                ? _buildErrorState(state.error!)
                : state.faqs.isEmpty && !state.isLoading
                  ? _buildEmptyState()
                  : _buildFAQList(state.faqs),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm câu hỏi...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (val) => ref.read(faqProvider.notifier).loadFAQs(
              category: _selectedCategory == 'Tất cả' ? null : _selectedCategory,
              query: val,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = cat);
                    ref.read(faqProvider.notifier).loadFAQs(
                      category: cat == 'Tất cả' ? null : cat,
                      query: _searchController.text,
                    );
                  },
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: _selectedCategory == cat ? Colors.white : Colors.black,
                  ),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQList(List<FAQ> faqs) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ExpansionTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: const Icon(Icons.help_center_outlined, color: Colors.blue),
            title: Text(faq.question, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 0),
                child: Text(faq.answer, 
                  style: const TextStyle(color: Colors.grey, height: 1.5)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
          TextButton(
            onPressed: () => ref.read(faqProvider.notifier).loadFAQs(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text('Không tìm thấy kết quả phù hợp', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
