import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/extensions/context_extension.dart';
import '../../../../review/presentation/controllers/review_controller.dart';
import '../../../../review/presentation/widgets/rating_bar.dart';

/// Tư vấn video — mở phòng họp Jitsi Meet (không cần API key).
class DoctorVideoConsultScreen extends StatelessWidget {
  const DoctorVideoConsultScreen({super.key, this.roomId});

  /// Định danh phòng tuỳ chọn (vd: mã lịch hẹn). Mặc định dựa trên uid bác sĩ.
  final String? roomId;

  String get _roomName {
    final id = roomId ??
        FirebaseAuth.instance.currentUser?.uid ??
        'guest';
    return 'icare-consult-$id';
  }

  String get _meetingUrl => 'https://meet.jit.si/$_roomName';

  Future<void> _join(BuildContext context) async {
    final uri = Uri.parse(_meetingUrl);
    final ok = await canLaunchUrl(uri);
    if (ok) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở phòng họp video.')),
      );
    }
  }

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _meetingUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép link phòng họp.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Tư vấn video'),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textPrimary,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.videocam_rounded,
                    size: 48, color: context.colors.primary),
              ),
              const SizedBox(height: 24),
              Text('Phòng tư vấn video',
                  style: context.textStyles.heading2, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'Cuộc gọi diễn ra qua Jitsi Meet. Chia sẻ link bên dưới cho bệnh nhân để cùng tham gia phòng họp.',
                textAlign: TextAlign.center,
                style: context.textStyles.body
                    .copyWith(color: context.colors.textSecondary),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.textSecondary
                      .withValues(alpha: 0.2)),
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(_meetingUrl,
                        style: context.textStyles.bodySmall,
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _copyLink(context),
                    child: Icon(Icons.copy_rounded,
                        size: 18, color: context.colors.primary),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _join(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.video_call_rounded),
                  label: const Text('Bắt đầu cuộc gọi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Đánh giá từ bệnh nhân cho bác sĩ đang đăng nhập (dữ liệu thật từ Firestore).
class DoctorPatientRatingsScreen extends ConsumerWidget {
  const DoctorPatientRatingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';

    Widget body;
    if (doctorId.isEmpty) {
      body = _emptyState(context, 'Chưa đăng nhập',
          'Đăng nhập bằng tài khoản bác sĩ để xem đánh giá.');
    } else {
      final state = ref.watch(doctorReviewControllerProvider(doctorId));
      if (state.isLoading && state.reviews.isEmpty) {
        body = const Center(child: CircularProgressIndicator());
      } else if (state.reviews.isEmpty) {
        body = _emptyState(context, 'Chưa có đánh giá',
            'Đánh giá của bệnh nhân sẽ hiển thị ở đây sau mỗi lượt khám.');
      } else {
        body = ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: state.reviews.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) return _summaryHeader(context, state);
            final r = state.reviews[i - 1];
            return _RatingTile(
              name: r.userName ?? 'Bệnh nhân',
              stars: r.rating.round(),
              comment: r.comment,
              date: r.createdAt,
            );
          },
        );
      }
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Đánh giá bệnh nhân'),
        backgroundColor: context.colors.surface,
        foregroundColor: context.colors.textPrimary,
        elevation: 0,
      ),
      body: body,
    );
  }

  Widget _summaryHeader(BuildContext context, ReviewState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Text(state.averageRating.toStringAsFixed(1),
            style: context.textStyles.heading1),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          RatingBar(rating: state.averageRating, size: 18),
          const SizedBox(height: 4),
          Text('${state.reviews.length} đánh giá',
              style: context.textStyles.bodySmall
                  .copyWith(color: context.colors.textSecondary)),
        ]),
      ]),
    );
  }

  Widget _emptyState(BuildContext context, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.reviews_outlined,
              size: 56, color: context.colors.textSecondary),
          const SizedBox(height: 16),
          Text(title, style: context.textStyles.bodyBold, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(subtitle,
              style: context.textStyles.bodySmall
                  .copyWith(color: context.colors.textSecondary),
              textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _RatingTile extends StatelessWidget {
  const _RatingTile({
    required this.name,
    required this.stars,
    required this.comment,
    this.date,
  });

  final String name;
  final int stars;
  final String comment;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(name, style: context.textStyles.bodyBold)),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            if (date != null) ...[
              const SizedBox(height: 2),
              Text('${date!.day}/${date!.month}/${date!.year}',
                  style: context.textStyles.bodySmall
                      .copyWith(color: context.colors.textSecondary)),
            ],
            const SizedBox(height: 8),
            Text(comment, style: context.textStyles.bodySmall.copyWith(color: context.colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
