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
    final articles = state.articles;
    final featuredArticles = articles.take(5).toList();
    final remainingArticles = articles.skip(5).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const BrandedAppBar(
        title: 'Tin tức y tế',
        showBackButton: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(newsProvider.notifier).loadNews(
              refresh: true,
              category: _selectedCategory == 'Tất cả' ? null : _selectedCategory,
            ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(child: _buildCategoryFilter()),
            if (state.isLoading && articles.isEmpty)
              SliverFillRemaining(
                child: Skeletonizer(
                  enabled: true,
                  child: _buildNewsList(List.generate(5, (index) => _mockArticle(index)), false),
                ),
              )
            else if (state.error != null && articles.isEmpty)
              SliverFillRemaining(child: _buildErrorState(state.error!))
            else ...[
              if (featuredArticles.isNotEmpty && _selectedCategory == 'Tất cả')
                SliverToBoxAdapter(child: _buildFeaturedSection(featuredArticles)),
              
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == remainingArticles.length) {
                        return state.isLoading 
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            : const SizedBox.shrink();
                      }
                      final article = remainingArticles[index];
                      return _buildCompactNewsCard(article);
                    },
                    childCount: remainingArticles.length + 1,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  HealthArticle _mockArticle(int index) => HealthArticle(
        id: 'mock_$index',
        title: 'Loading interesting news title here...',
        summary: 'This is a brief summary of the news that is currently loading...',
        source: 'Source',
        publishedAt: DateTime.now(),
      );

  Widget _buildFeaturedSection(List<HealthArticle> articles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Tin nổi bật',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: articles.length,
            itemBuilder: (context, index) => _buildFeaturedCard(articles[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(HealthArticle article) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: article.imageUrl != null
                  ? Image.network(article.imageUrl!, fit: BoxFit.cover)
                  : Container(color: Colors.blueGrey[100]),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      article.source,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getTimeAgo(article.publishedAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactNewsCard(HealthArticle article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => article.articleUrl != null ? _launchURL(article.articleUrl!) : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (article.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    article.imageUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.source.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeAgo(article.publishedAt),
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7) return DateFormat('dd/MM/yyyy').format(date);
    if (diff.inDays >= 1) return '${diff.inDays} ngày trước';
    if (diff.inHours >= 1) return '${diff.inHours} giờ trước';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
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
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: articles.length,
      itemBuilder: (context, index) => _buildCompactNewsCard(articles[index]),
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
