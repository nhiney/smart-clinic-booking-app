import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_clinic_booking/core/theme/icare_tokens.dart';
import '../controllers/admin_controller.dart';

class AdminReviewModerationScreen extends StatefulWidget {
  const AdminReviewModerationScreen({super.key});

  @override
  State<AdminReviewModerationScreen> createState() => _AdminReviewModerationScreenState();
}

class _AdminReviewModerationScreenState extends State<AdminReviewModerationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchAllReviews();
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AdminController>();
    final all = ctrl.allReviews;
    final visible = all.where((r) => r['isHidden'] != true).toList();
    final hidden = all.where((r) => r['isHidden'] == true).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _buildAppBar(),
          _buildTabBar(),
        ],
        body: ctrl.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabCtrl,
                children: [
                  _ReviewList(reviews: all, onToggleHide: _toggleHide, onDelete: _delete),
                  _ReviewList(reviews: visible, onToggleHide: _toggleHide, onDelete: _delete),
                  _ReviewList(reviews: hidden, onToggleHide: _toggleHide, onDelete: _delete),
                ],
              ),
      ),
    );
  }

  void _toggleHide(String id, bool currentlyHidden) async {
    await context.read<AdminController>().setReviewHidden(id, hidden: !currentlyHidden);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentlyHidden ? 'Đã hiển thị đánh giá' : 'Đã ẩn đánh giá'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: currentlyHidden ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  void _delete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa đánh giá?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Thao tác này không thể hoàn tác. Đánh giá sẽ bị xóa vĩnh viễn.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AdminController>().deleteReview(id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa đánh giá'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFDC2626),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB91C1C), Color(0xFFEF4444)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kiểm duyệt đánh giá',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('Xem xét và quản lý đánh giá của bệnh nhân',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
        collapseMode: CollapseMode.parallax,
      ),
      leading: const BackButton(color: Colors.white),
      bottom: const PreferredSize(preferredSize: Size.fromHeight(48), child: SizedBox()),
    );
  }

  SliverPersistentHeader _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabCtrl,
          labelColor: const Color(0xFFDC2626),
          unselectedLabelColor: const Color(0xFF94A3B8),
          indicatorColor: const Color(0xFFDC2626),
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [Tab(text: 'Tất cả'), Tab(text: 'Hiển thị'), Tab(text: 'Đã ẩn')],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}

class _ReviewList extends StatelessWidget {
  final List<Map<String, dynamic>> reviews;
  final void Function(String id, bool isHidden) onToggleHide;
  final void Function(String id) onDelete;

  const _ReviewList({required this.reviews, required this.onToggleHide, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('Không có đánh giá nào', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _ReviewCard(
        data: reviews[i],
        onToggleHide: onToggleHide,
        onDelete: onDelete,
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final void Function(String id, bool isHidden) onToggleHide;
  final void Function(String id) onDelete;

  const _ReviewCard({required this.data, required this.onToggleHide, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final id = data['id'] as String? ?? '';
    final comment = data['comment'] as String? ?? '';
    final userName = data['userName'] as String? ?? 'Bệnh nhân';
    final doctorId = data['doctorId'] as String? ?? '';
    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
    final isHidden = data['isHidden'] == true;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isHidden ? const Color(0xFFFFF7F7) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isHidden ? Border.all(color: Colors.red.withValues(alpha: 0.2)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: IColors.primary500.withValues(alpha: 0.1),
                  child: Text(
                    userName.isNotEmpty ? userName.trim().split(' ').last.substring(0, 1).toUpperCase() : 'U',
                    style: const TextStyle(color: IColors.primary500, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                      if (doctorId.isNotEmpty)
                        Text('Bác sĩ: ${doctorId.length > 20 ? doctorId.substring(0, 16) + '...' : doctorId}',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    ],
                  ),
                ),
                _StarRow(rating: rating),
                if (isHidden)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Text('Đã ẩn', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            if (comment.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(comment, style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.45), maxLines: 4, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onToggleHide(id, isHidden),
                    icon: Icon(isHidden ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 16),
                    label: Text(isHidden ? 'Hiển thị' : 'Ẩn đi', style: const TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isHidden ? Colors.green : Colors.orange,
                      side: BorderSide(color: isHidden ? Colors.green : Colors.orange),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onDelete(id),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Xóa', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: const Color(0xFFF59E0B),
        );
      }),
    );
  }
}
