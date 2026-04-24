import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_clinic_booking/features/content/domain/entities/content_entities.dart';
import 'package:smart_clinic_booking/features/content/presentation/controllers/content_controller.dart';

class HealthLibraryScreen extends ConsumerStatefulWidget {
  const HealthLibraryScreen({super.key});

  @override
  ConsumerState<HealthLibraryScreen> createState() => _HealthLibraryScreenState();
}

class _HealthLibraryScreenState extends ConsumerState<HealthLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';

  static const _categories = [
    'Tất cả',
    'Tim mạch',
    'Tiểu đường',
    'Dinh dưỡng',
    'Tâm lý',
    'Cơ xương khớp',
    'Hô hấp',
    'Nhi khoa',
  ];

  static const _kPrimary = Color(0xFF0D62A2);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthLibraryProvider.notifier).loadArticles();
      final uid = legacy.Provider.of<AuthController>(context, listen: false).currentUser?.id;
      if (uid != null) {
        ref.read(healthLibraryProvider.notifier).loadBookmarks(uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String get _selectedCategory {
    final idx = _tabController.index;
    return idx == 0 ? '' : _categories[idx];
  }

  List<HealthLibraryArticle> _filtered(List<HealthLibraryArticle> all) {
    var list = all;
    if (_selectedCategory.isNotEmpty) {
      list = list.where((a) => a.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((a) => a.title.toLowerCase().contains(q) || a.tags.any((t) => t.toLowerCase().contains(q))).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(healthLibraryProvider);
    final auth = legacy.Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5FB),
      appBar: BrandedAppBar(
        title: 'Thư viện sức khoẻ',
        showBackButton: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            tabAlignment: TabAlignment.start,
            onTap: (_) => setState(() {}),
            tabs: _categories.map((c) => Tab(text: c)).toList(),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),
          // Articles
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? _buildEmpty('Không thể tải bài viết', Icons.error_outline)
                    : _buildArticleList(state, auth),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bài viết sức khoẻ...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _kPrimary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleList(LibraryState state, AuthController auth) {
    final articles = _filtered(state.articles);
    if (articles.isEmpty) return _buildEmpty('Không có bài viết nào', Icons.article_outlined);
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(healthLibraryProvider.notifier).loadArticles(
          category: _selectedCategory.isEmpty ? null : _selectedCategory,
          searchQuery: _query.isEmpty ? null : _query,
        );
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: articles.length,
        itemBuilder: (context, i) {
          final article = articles[i];
          return _ArticleCard(
            article: article,
            onBookmark: () {
              final uid = auth.currentUser?.id;
              if (uid != null) {
                ref.read(healthLibraryProvider.notifier).toggleBookmark(uid, article.id);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEmpty(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final HealthLibraryArticle article;
  final VoidCallback onBookmark;

  const _ArticleCard({required this.article, required this.onBookmark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Image.network(
                  article.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(),
                ),
              )
            else
              _placeholderImage(),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CategoryChip(article.category),
                      const Spacer(),
                      GestureDetector(
                        onTap: onBookmark,
                        child: Icon(
                          article.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 20,
                          color: article.isBookmarked ? const Color(0xFF0D62A2) : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B), height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.content,
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(article.publishedAt),
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                      const Spacer(),
                      if (article.tags.isNotEmpty)
                        ...article.tags.take(2).map((t) => Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(t, style: const TextStyle(fontSize: 10, color: Color(0xFF0D62A2), fontWeight: FontWeight.w500)),
                          ),
                        )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: Container(
        height: 120,
        width: double.infinity,
        color: const Color(0xFFEFF6FF),
        child: const Center(
          child: Icon(Icons.health_and_safety_rounded, size: 48, color: Color(0xFF93C5FD)),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ArticleDetailSheet(article: article),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip(this.label);

  static const _colors = {
    'Tim mạch': Color(0xFFEF4444),
    'Tiểu đường': Color(0xFFF97316),
    'Dinh dưỡng': Color(0xFF22C55E),
    'Tâm lý': Color(0xFF8B5CF6),
    'Cơ xương khớp': Color(0xFF0EA5E9),
    'Hô hấp': Color(0xFF06B6D4),
    'Nhi khoa': Color(0xFFEC4899),
  };

  @override
  Widget build(BuildContext context) {
    final color = _colors[label] ?? const Color(0xFF0D62A2);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _ArticleDetailSheet extends StatelessWidget {
  final HealthLibraryArticle article;
  const _ArticleDetailSheet({required this.article});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.imageUrl != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          article.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _CategoryChip(article.category),
                    const SizedBox(height: 12),
                    Text(article.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.3, color: Color(0xFF1E293B))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(article.publishedAt),
                          style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      article.content,
                      style: const TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF334155)),
                    ),
                    if (article.tags.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text('Từ khoá', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: article.tags.map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(t, style: const TextStyle(fontSize: 12, color: Color(0xFF0D62A2))),
                        )).toList(),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
