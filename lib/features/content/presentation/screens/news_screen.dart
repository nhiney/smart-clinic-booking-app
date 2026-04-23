import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:smart_clinic_booking/features/content/presentation/controllers/content_controller.dart';
import 'package:smart_clinic_booking/features/home/domain/entities/health_article.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = ['Tất cả', 'Dinh dưỡng', 'Tiểu đường', 'Tim mạch', 'Sức khỏe tâm thần'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(newsProvider.notifier).loadNews(refresh: true));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(newsProvider.notifier).loadNews(category: _selectedCategory == 'Tất cả' ? null : _selectedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const BrandedAppBar(
        title: 'Tin tức y tế',
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(newsProvider.notifier).loadNews(refresh: true, category: _selectedCategory == 'Tất cả' ? null : _selectedCategory),
        child: Column(
          children: [
            _buildCategoryFilter(),
            Expanded(
              child: Skeletonizer(
                enabled: state.isLoading && state.articles.isEmpty,
                child: state.error != null && state.articles.isEmpty
                  ? _buildErrorState(state.error!)
                  : _buildNewsList(state.articles, state.isLoading),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: _categories.map((cat) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: _selectedCategory == cat,
              onSelected: (selected) {
                setState(() => _selectedCategory = cat);
                ref.read(newsProvider.notifier).loadNews(
                  refresh: true,
                  category: cat == 'Tất cả' ? null : cat,
                );
              },
              selectedColor: const Color(0xFF2563EB),
              labelStyle: TextStyle(
                color: _selectedCategory == cat ? Colors.white : Colors.black,
                fontWeight: _selectedCategory == cat ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildNewsList(List<HealthArticle> articles, bool isLoading) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: articles.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == articles.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final article = articles[index];
        return _buildNewsCard(article);
      },
    );
  }

  Widget _buildNewsCard(HealthArticle article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => article.articleUrl != null ? _launchURL(article.articleUrl!) : null,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  article.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 180,
                    color: Colors.grey.withOpacity(0.1),
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(article.source, 
                          style: const TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const Spacer(),
                      Text(DateFormat('dd/MM/yyyy').format(article.publishedAt), 
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(article.title, 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.3)),
                  const SizedBox(height: 8),
                  Text(article.summary, 
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
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
            onPressed: () => ref.read(newsProvider.notifier).loadNews(refresh: true),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
