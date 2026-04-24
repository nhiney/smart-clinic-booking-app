import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:smart_clinic_booking/core/theme/colors/app_colors.dart';
import 'package:smart_clinic_booking/core/theme/typography/app_text_styles.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_clinic_booking/features/review/presentation/controllers/review_controller.dart';
import 'package:smart_clinic_booking/features/review/presentation/widgets/rating_bar.dart';
import 'package:smart_clinic_booking/shared/widgets/loading_widget.dart';
import 'package:smart_clinic_booking/shared/widgets/empty_state_widget.dart';

class DoctorReviewScreen extends ConsumerWidget {
  final String doctorId;
  final String doctorName;

  const DoctorReviewScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(doctorReviewControllerProvider(doctorId));
    final auth = legacy.Provider.of<AuthController>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandedAppBar(title: 'Đánh giá: $doctorName', showBackButton: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddReviewDialog(context, ref, auth),
        label: const Text('Viết đánh giá', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.edit, color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
      body: state.isLoading
          ? const LoadingWidget(itemCount: 3)
          : Column(
              children: [
                _buildHeader(state),
                const Divider(height: 1),
                Expanded(
                  child: state.reviews.isEmpty
                      ? const EmptyStateWidget(
                          title: 'Chưa có đánh giá nào. Hãy là người đầu tiên!',
                          icon: Icons.rate_review_outlined,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.reviews.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) => _buildReviewCard(state.reviews[index]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(ReviewState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                state.averageRating.toStringAsFixed(1),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              RatingBar(rating: state.averageRating, size: 20),
              const SizedBox(height: 4),
              Text('${state.reviews.length} đánh giá', style: AppTextStyles.bodySmall),
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
                      Text('$star', style: AppTextStyles.bodySmall),
                      const SizedBox(width: 6),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.amber,
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('$count', style: AppTextStyles.bodySmall),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(dynamic review) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primarySurface,
                backgroundImage: review.userAvatar != null ? NetworkImage(review.userAvatar!) : null,
                child: review.userAvatar == null ? const Icon(Icons.person, color: AppColors.primary) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName ?? 'Người dùng', style: AppTextStyles.bodyBold),
                    Text(
                      '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                    ),
                  ],
                ),
              ),
              RatingBar(rating: review.rating, size: 14),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.comment, style: AppTextStyles.body),
        ],
      ),
    );
  }

  void _showAddReviewDialog(BuildContext context, WidgetRef ref, AuthController auth) {
    if (auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đánh giá')),
      );
      return;
    }

    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Đánh giá bác sĩ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Chọn số sao:', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              const SizedBox(height: 8),
              RatingBar(
                rating: selectedRating,
                size: 36,
                onRatingUpdate: (r) => setModalState(() => selectedRating = r),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Chia sẻ trải nghiệm khám của bạn...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
            ElevatedButton(
              onPressed: () async {
                if (commentController.text.trim().isEmpty) return;
                final success = await ref.read(doctorReviewControllerProvider(doctorId).notifier).addReview(
                  userId: auth.currentUser!.id,
                  hospitalId: '',
                  rating: selectedRating,
                  comment: commentController.text.trim(),
                  userName: auth.currentUser!.name,
                );
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Cảm ơn bạn đã đánh giá!' : 'Bạn đã đánh giá rồi.'),
                      backgroundColor: success ? Colors.green : Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Gửi đánh giá', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
