import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:smart_clinic_booking/core/theme/colors/app_colors.dart';
import 'package:smart_clinic_booking/core/theme/typography/app_text_styles.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_clinic_booking/features/content/domain/entities/content_entities.dart';
import 'package:smart_clinic_booking/features/content/presentation/controllers/content_controller.dart';
import 'package:smart_clinic_booking/shared/widgets/glass_morphic_container.dart';

class HealthLibraryScreen extends ConsumerStatefulWidget {
  const HealthLibraryScreen({super.key});

  @override
  ConsumerState<HealthLibraryScreen> createState() => _HealthLibraryScreenState();
}

class _HealthLibraryScreenState extends ConsumerState<HealthLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
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
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildSearchBar(context)),
          if (state.isLoading)
            const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
          else if (state.error != null)
            SliverFillRemaining(child: _buildEmpty(context, 'Không thể tải bài viết', Icons.error_outline_rounded))
          else
            _buildSliverArticleList(context, state, auth),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: context.colors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Thư viện sức khoẻ',
          style: context.textStyles.bodyBold.copyWith(color: Colors.white),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.primary, context.colors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(Icons.library_books_rounded, size: 140, color: Colors.white.withOpacity(0.1)),
              ),
            ],
          ),
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Colors.transparent,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            tabAlignment: TabAlignment.start,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            onTap: (_) => setState(() {}),
            tabs: _categories.map((c) => Tab(text: c)).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bài viết sức khoẻ...',
          hintStyle: context.textStyles.bodySmall.copyWith(color: context.colors.textHint),
          prefixIcon: Icon(Icons.search_rounded, color: context.colors.primary, size: 22),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: context.colors.textHint),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
              : null,
          filled: true,
          fillColor: context.colors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: context.radius.mRadius,
            borderSide: BorderSide(color: context.colors.divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: context.radius.mRadius,
            borderSide: BorderSide(color: context.colors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: context.radius.mRadius,
            borderSide: BorderSide(color: context.colors.primary, width: 1.5),
          ),
        ),
        style: context.textStyles.body,
      ),
    );
  }

  Widget _buildSliverArticleList(BuildContext context, LibraryState state, AuthController auth) {
    final articles = _filtered(state.articles);
    if (articles.isEmpty) {
      return SliverFillRemaining(child: _buildEmpty(context, 'Không có bài viết nào', Icons.article_outlined));
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final article = articles[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _ArticleCard(
                article: article,
                onBookmark: () {
                  final uid = auth.currentUser?.id;
                  if (uid != null) {
                    ref.read(healthLibraryProvider.notifier).toggleBookmark(uid, article.id);
                  }
                },
              ),
            );
          },
          childCount: articles.length,
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 60, color: context.colors.textHint.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(message, style: context.textStyles.body.copyWith(color: context.colors.textSecondary)),
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
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: context.radius.mRadius,
          boxShadow: [
            BoxShadow(color: context.colors.primary.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: context.radius.mRadius.topLeft),
                child: Image.network(
                  article.imageUrl!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderImage(context),
                ),
              )
            else
              _placeholderImage(context),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CategoryChip(article.category),
                      const Spacer(),
                      IconButton(
                        onPressed: onBookmark,
                        icon: Icon(
                          article.isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 24,
                          color: article.isBookmarked ? context.colors.primary : context.colors.textHint,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.title,
                    style: context.textStyles.bodyBold.copyWith(fontSize: 16, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.content,
                    style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary, height: 1.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 14, color: context.colors.textHint),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd/MM/yyyy').format(article.publishedAt),
                        style: context.textStyles.bodySmall.copyWith(color: context.colors.textHint),
                      ),
                      const Spacer(),
                      if (article.tags.isNotEmpty)
                        ...article.tags.take(1).map((t) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.colors.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(t,
                                  style: context.textStyles.bodySmall
                                      .copyWith(color: context.colors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
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

  Widget _placeholderImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: context.radius.mRadius.topLeft),
      child: Container(
        height: 120,
        width: double.infinity,
        color: context.colors.primary.withOpacity(0.05),
        child: Center(
          child: Icon(Icons.health_and_safety_rounded, size: 48, color: context.colors.primary.withOpacity(0.2)),
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
    final color = _colors[label] ?? context.colors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
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
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: context.colors.divider, borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.imageUrl != null)
                      ClipRRect(
                        borderRadius: context.radius.mRadius,
                        child: Image.network(
                          article.imageUrl!,
                          height: 220,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _CategoryChip(article.category),
                    const SizedBox(height: 16),
                    Text(article.title, style: context.textStyles.heading3.copyWith(fontSize: 22, height: 1.3)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: context.colors.textHint),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd/MM/yyyy').format(article.publishedAt),
                          style: context.textStyles.bodySmall.copyWith(color: context.colors.textHint),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text(
                      article.content,
                      style: context.textStyles.body.copyWith(height: 1.8, color: context.colors.textPrimary.withOpacity(0.8)),
                    ),
                    if (article.tags.isNotEmpty) ...[
                      const SizedBox(height: 32),
                      Text('Từ khoá liên quan', style: context.textStyles.bodyBold),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: article.tags
                            .map((t) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: context.colors.primary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(t, style: context.textStyles.bodySmall.copyWith(color: context.colors.primary)),
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 60),
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

