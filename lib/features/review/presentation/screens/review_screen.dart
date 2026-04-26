import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:smart_clinic_booking/core/theme/colors/app_colors.dart';
import 'package:smart_clinic_booking/core/theme/typography/app_text_styles.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';
import 'package:smart_clinic_booking/shared/widgets/loading_widget.dart';
import 'package:smart_clinic_booking/shared/widgets/empty_state_widget.dart';
import 'package:smart_clinic_booking/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_clinic_booking/features/review/presentation/controllers/review_controller.dart';
import 'package:smart_clinic_booking/features/review/presentation/widgets/rating_bar.dart';
import 'package:smart_clinic_booking/shared/widgets/glass_morphic_container.dart';

class ReviewScreen extends ConsumerWidget {
  final String hospitalId;
  final String hospitalName;

  const ReviewScreen({
    super.key,
    required this.hospitalId,
    required this.hospitalName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewControllerProvider(hospitalId));
    final authController = legacy_provider.Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              if (state.isLoading)
                const SliverFillRemaining(child: Center(child: LoadingWidget(itemCount: 3)))
              else ...[
                SliverToBoxAdapter(child: _buildHeader(context, state)),
                const SliverToBoxAdapter(child: Divider()),
                if (state.reviews.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyStateWidget(
                      title: "Chưa có đánh giá nào. Hãy là người đầu tiên!",
                      icon: Icons.rate_review_outlined,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final review = state.reviews[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildReviewCard(context, review),
                          );
                        },
                        childCount: state.reviews.length,
                      ),
                    ),
                  ),
              ],
            ],
          ),
          _buildFab(context, ref, authController),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: context.colors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          hospitalName,
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
                child: Icon(Icons.star_rounded, size: 120, color: Colors.white.withOpacity(0.1)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ReviewState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                children: [
                  Text(
                    state.averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: context.colors.primary,
                    ),
                  ),
                  RatingBar(rating: state.averageRating, size: 20),
                  const SizedBox(height: 8),
                  Text(
                    "${state.reviews.length} đánh giá",
                    style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final star = 5 - index;
                    final count = state.reviews.where((r) => r.rating.round() == star).length;
                    final percent = state.reviews.isEmpty ? 0.0 : count / state.reviews.length;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Text("$star", style: context.textStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percent,
                                backgroundColor: context.colors.divider.withOpacity(0.5),
                                color: Colors.amber,
                                minHeight: 6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, dynamic review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.mRadius,
        boxShadow: [
          BoxShadow(color: context.colors.primary.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.colors.primary.withOpacity(0.1),
                backgroundImage: review.userAvatar != null ? NetworkImage(review.userAvatar!) : null,
                child: review.userAvatar == null
                    ? Icon(Icons.person_rounded, color: context.colors.primary, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName ?? "Người dùng", style: context.textStyles.bodyBold),
                    Text(
                      "${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}",
                      style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
              RatingBar(rating: review.rating, size: 14),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: context.textStyles.body.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context, WidgetRef ref, AuthController auth) {
    return Positioned(
      bottom: 24,
      right: 24,
      child: FloatingActionButton.extended(
        onPressed: () => _showAddReviewDialog(context, ref, auth),
        label: const Text("Viết đánh giá", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.edit_rounded, color: Colors.white),
        backgroundColor: context.colors.primary,
        elevation: 8,
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, WidgetRef ref, AuthController auth) {
    if (auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng đăng nhập để đánh giá")));
      return;
    }

    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: context.radius.mRadius),
          title: Text("Viết đánh giá của bạn", style: context.textStyles.bodyBold.copyWith(fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final star = index + 1;
                  final isSelected = selectedRating >= star;
                  return GestureDetector(
                    onTap: () => setState(() => selectedRating = star.toDouble()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: isSelected ? Colors.amber : context.colors.textHint,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Nhập cảm nhận của bạn...",
                  hintStyle: context.textStyles.bodySmall,
                  border: OutlineInputBorder(borderRadius: context.radius.sRadius),
                  filled: true,
                  fillColor: context.colors.divider.withOpacity(0.1),
                ),
                style: context.textStyles.body,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Hủy", style: TextStyle(color: context.colors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.isEmpty) return;
                final success = await ref.read(reviewControllerProvider(hospitalId).notifier).addReview(
                      userId: auth.currentUser!.id,
                      rating: selectedRating,
                      comment: commentController.text,
                      userName: auth.currentUser!.name,
                    );
                if (success && context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Cảm ơn bạn đã đánh giá!"), backgroundColor: AppColors.success),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.primary,
                shape: RoundedRectangleBorder(borderRadius: context.radius.sRadius),
              ),
              child: const Text("Gửi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

