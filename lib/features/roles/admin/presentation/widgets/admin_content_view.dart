import 'package:flutter/material.dart';
import '../../domain/entities/facility_entities.dart';
import '../screens/add_article_screen.dart';
import '../controllers/admin_controller.dart';
import 'package:provider/provider.dart';

class AdminContentView extends StatefulWidget {
  final List<ArticleEntity> articles;

  const AdminContentView({super.key, required this.articles});

  @override
  State<AdminContentView> createState() => _AdminContentViewState();
}

class _AdminContentViewState extends State<AdminContentView> {
  String _activeTab = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final totalArticles = widget.articles.length;
    final totalViews = widget.articles.fold<int>(0, (sum, item) => sum + item.views);

    final publishedCount = widget.articles.where((a) => a.status == 'Đã xuất bản').length;
    final draftingCount = widget.articles.where((a) => a.status == 'Đang soạn' || a.status == 'Nháp').length;

    final filteredList = widget.articles.where((article) {
      if (_activeTab == 'Đã xuất bản') return article.status == 'Đã xuất bản';
      if (_activeTab == 'Nháp') return article.status == 'Đang soạn' || article.status == 'Nháp';
      return true;
    }).toList();

    final ArticleEntity? topArticle = widget.articles.isNotEmpty
        ? widget.articles.reduce((a, b) => a.views > b.views ? a : b)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nội dung', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                      const SizedBox(height: 4),
                      Text(
                        '$totalArticles bài · ${(totalViews / 1000).toStringAsFixed(0)}K lượt xem tuần này',
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddArticleScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text('Bài mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            if (topArticle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TUẦN NÀY', style: TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 6),
                            Text(topArticle.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF78350F), height: 1.3)),
                            const SizedBox(height: 8),
                            Text('BS. ${topArticle.authorName}', style: const TextStyle(color: Color(0xFF92400E), fontSize: 12, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        children: [
                          Text('${(topArticle.views / 1000).toStringAsFixed(1)}K', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFFB45309))),
                          const Text('lượt xem', style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w500)),
                        ],
                      )
                    ],
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Row(
                children: [
                  _buildTabButton('Tất cả', totalArticles),
                  _buildTabButton('Đã xuất bản', publishedCount),
                  _buildTabButton('Nháp', draftingCount),
                ],
              ),
            ),

            Expanded(
              child: filteredList.isEmpty
                  ? const Center(child: Text('Không có bài viết nào phù hợp.', style: TextStyle(color: Color(0xFF94A3B8))))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final article = filteredList[index];
                        return _buildArticleItem(article, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int count) {
    final isSelected = _activeTab == title;
    return InkWell(
      onTap: () => setState(() => _activeTab = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isSelected ? const Color(0xFF0F172A) : Colors.transparent, width: 2)),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 6),
            Text('$count', style: TextStyle(fontSize: 12, color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleItem(ArticleEntity article, int index) {
    final List<List<Color>> gradientColors = [
      [const Color(0xFF7DD3FC), const Color(0xFF0284C7)],
      [const Color(0xFFFBCFE8), const Color(0xFFDB2777)],
      [const Color(0xFFA7F3D0), const Color(0xFF059669)],
    ];
    final currentGradients = gradientColors[index % gradientColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(colors: currentGradients, begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: const Icon(Icons.description_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(article.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text('BS. ${article.authorName} · ${article.category}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: article.status == 'Đã xuất bản' ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        article.status,
                        style: TextStyle(color: article.status == 'Đã xuất bản' ? const Color(0xFF15803D) : const Color(0xFFB45309), fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('${(article.views / 1000).toStringAsFixed(1)}K views', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    const SizedBox(width: 6),
                    const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                    const SizedBox(width: 6),
                    Text(article.publishDate, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  ],
                )
              ],
            ),
          ),
          PopupMenuButton<String>(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8), size: 20),
            onSelected: (value) {
              if (value == 'edit') {
                _handleEditArticle(article);
              } else if (value == 'delete') {
                _handleDeleteArticle(context, article);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, color: Color(0xFF64748B), size: 18),
                    SizedBox(width: 10),
                    Text('Chỉnh sửa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Colors.red, size: 18),
                    SizedBox(width: 10),
                    Text('Xóa bài', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleEditArticle(ArticleEntity article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddArticleScreen(article: article),
      ),
    );
  }

  void _handleDeleteArticle(BuildContext context, ArticleEntity article) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn xóa bài viết "${article.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AdminController>(context, listen: false).deleteArticle(article.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}