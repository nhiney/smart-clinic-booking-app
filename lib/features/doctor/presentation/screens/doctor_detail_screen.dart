import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import "package:smart_clinic_booking/apps/shared/di/injection.dart";
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../../core/widgets/icare_logo.dart';
import '../../domain/entities/doctor_entity.dart';
import '../../domain/usecases/get_catalog_doctor_detail_usecase.dart';
class DoctorDetailScreen extends StatefulWidget {
  final DoctorEntity? doctor;
  final String? doctorId;

  const DoctorDetailScreen({
    super.key,
    this.doctor,
    this.doctorId,
  }) : assert(doctor != null || doctorId != null, 'Either doctor or doctorId must be provided');

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  late DoctorEntity _doctor;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.doctor != null) {
      _doctor = widget.doctor!;
    } else {
      // Temporary stub while hydrating from remote
      _doctor = DoctorEntity(
        id: widget.doctorId!,
        name: '',
        specialty: '',
      );
    }
    _hydrateFromRemote();
  }

  Future<void> _hydrateFromRemote() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final fresh =
          await getIt<GetCatalogDoctorDetailUseCase>().call(_doctor.id);
      if (!mounted) return;
      if (fresh != null) {
        setState(() => _doctor = fresh);
      }
    } catch (e) {
      if (!mounted) return;
      if (e is FirebaseException) {
        _error = e.message ?? e.code;
      } else {
        _error = e.toString();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (_error != null)
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _hydrateFromRemote,
                ),
            ],
            title: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ICareLogo(size: 28, showText: false, isLight: true),
                SizedBox(width: 8),
                Text(
                  "ICARE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 56),
                    _buildAvatar(),
                    const SizedBox(height: 10),
                    Text(
                      _titleName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _doctor.specialty.isNotEmpty
                          ? _doctor.specialty
                          : 'Chuyên khoa đang cập nhật',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_loading)
                    const LinearProgressIndicator(minHeight: 2),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Không tải được đầy đủ thông tin mới nhất: $_error',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      _buildStatCard(
                        icon: Icons.star,
                        value: _doctor.rating > 0
                            ? _doctor.rating.toStringAsFixed(1)
                            : '—',
                        label: "Đánh giá",
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.work_history,
                        value: _doctor.experience > 0
                            ? "${_doctor.experience}"
                            : '—',
                        label: "Năm KN",
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        icon: Icons.reviews_outlined,
                        value: _doctor.totalReviews > 0
                            ? "${_doctor.totalReviews}"
                            : '—',
                        label: "Lượt ĐG",
                        color: AppColors.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text("Giới thiệu", style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(
                    _doctor.about.isNotEmpty
                        ? _doctor.about
                        : "Chưa có thông tin giới thiệu.",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text("Phòng khám / Bệnh viện", style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(color: AppColors.shadow, blurRadius: 8),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_hospital,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _doctor.displayClinic.isNotEmpty
                                    ? _doctor.displayClinic
                                    : 'Đang cập nhật',
                                style: AppTextStyles.subtitle,
                              ),
                              if (_doctor.location.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.place_outlined,
                                      size: 16,
                                      color: AppColors.textHint,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        _doctor.location,
                                        style: AppTextStyles.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text("Lịch làm việc", style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  _buildSchedule(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.push(
                          '/patient/create-appointment',
                          extra: {'doctor': _doctor},
                        );
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text("Đặt lịch khám"),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _titleName =>
      _doctor.name.isNotEmpty ? _doctor.name : 'Bác sĩ';

  Widget _buildAvatar() {
    final url = _doctor.imageUrl;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.white24,
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.white,
        child: url.isNotEmpty
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: url,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.person,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              )
            : const Icon(
                Icons.person,
                size: 40,
                color: AppColors.primary,
              ),
      ),
    );
  }

  Widget _buildSchedule() {
    if (_doctor.schedule.isNotEmpty) {
      return Column(
        children: _doctor.schedule.map((day) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(color: AppColors.shadow, blurRadius: 4),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day.day,
                  style: AppTextStyles.subtitle
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                if (day.slots.isEmpty)
                  Text(
                    'Chưa có khung giờ',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: day.slots.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          t,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          );
        }).toList(),
      );
    }

    if (_doctor.availableDays.isNotEmpty ||
        _doctor.availableTimeSlots.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_doctor.availableDays.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _doctor.availableDays.map((d) {
                return Chip(
                  label: Text(d, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.primarySurface,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
          if (_doctor.availableTimeSlots.isNotEmpty) ...[
            Text("Khung giờ", style: AppTextStyles.bodySmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _doctor.availableTimeSlots.map((time) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    time,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      );
    }

    return Text(
      'Lịch làm việc đang được cập nhật.',
      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: AppColors.shadow, blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
