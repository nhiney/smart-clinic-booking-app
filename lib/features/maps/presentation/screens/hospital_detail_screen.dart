import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../domain/entities/hospital_entity.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/entities/clinic_room_entity.dart';
import '../controllers/hospital_detail_controller.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';

// ─────────────────────────── icon helper ────────────────────────────────────

IconData _deptIcon(String name) {
  const map = {
    'favorite': Icons.favorite_rounded,
    'medical_services': Icons.medical_services_rounded,
    'emergency': Icons.emergency_rounded,
    'psychology': Icons.psychology_rounded,
    'biotech': Icons.biotech_rounded,
    'accessible': Icons.accessible_rounded,
    'child_care': Icons.child_care_rounded,
    'visibility': Icons.visibility_rounded,
    'pregnant_woman': Icons.pregnant_woman_rounded,
    'local_hospital': Icons.local_hospital_rounded,
    'healing': Icons.healing_rounded,
    'science': Icons.science_rounded,
  };
  return map[name] ?? Icons.local_hospital_rounded;
}

Color _roomStatusColor(String status) {
  switch (status) {
    case 'available':
      return AppColors.success;
    case 'occupied':
      return AppColors.warning;
    case 'closed':
      return AppColors.error;
    default:
      return AppColors.textHint;
  }
}

String _roomStatusLabel(String status) {
  switch (status) {
    case 'available':
      return 'Sẵn sàng';
    case 'occupied':
      return 'Đang khám';
    case 'closed':
      return 'Đóng cửa';
    default:
      return status;
  }
}

// ─────────────────────────── persistent tab bar header ──────────────────────

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;

  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          tabBar,
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

// ─────────────────────────── main screen ────────────────────────────────────

class HospitalDetailScreen extends ConsumerStatefulWidget {
  final String hospitalId;
  final HospitalEntity? hospital;

  const HospitalDetailScreen({
    super.key,
    required this.hospitalId,
    this.hospital,
  });

  @override
  ConsumerState<HospitalDetailScreen> createState() => _HospitalDetailScreenState();
}

class _HospitalDetailScreenState extends ConsumerState<HospitalDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _defaultImage =
      'https://images.unsplash.com/photo-1587350859728-117699f4a13d?auto=format&fit=crop&q=80&w=800';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resolve hospital: use passed entity or fetch from Firestore
    HospitalEntity? hospital = widget.hospital;
    if (hospital == null) {
      final asyncHospital = ref.watch(hospitalByIdProvider(widget.hospitalId));
      return asyncHospital.when(
        loading: () => Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết bệnh viện'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: Center(child: Text('Lỗi tải dữ liệu: $e')),
        ),
        data: (h) {
          if (h == null) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Chi tiết bệnh viện'),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                ),
              ),
              body: const Center(child: Text('Không tìm thấy thông tin bệnh viện.')),
            );
          }
          return _buildScaffold(context, h);
        },
      );
    }
    return _buildScaffold(context, hospital);
  }

  Widget _buildScaffold(BuildContext context, HospitalEntity h) {
    final imageUrl = h.imageUrl?.isNotEmpty == true ? h.imageUrl! : _defaultImage;
    final tabBar = TabBar(
      controller: _tabController,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorWeight: 3,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      tabs: const [
        Tab(text: 'Tổng quan'),
        Tab(text: 'Khoa & Phòng khám'),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: AppColors.divider),
                  errorWidget: (_, __, ___) => Container(color: AppColors.divider),
                ),
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: IconButton(
                      icon: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 18),
                      onPressed: () => context.push('/patient/create-appointment'),
                      tooltip: 'Đặt lịch',
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: _HospitalInfoHeader(hospital: h),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(tabBar),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _OverviewTab(hospital: h),
            _DepartmentsTab(hospitalId: widget.hospitalId),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => context.push('/patient/create-appointment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Đặt lịch khám',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────── info header (sliver) ───────────────────────────

class _HospitalInfoHeader extends StatelessWidget {
  final HospitalEntity hospital;

  const _HospitalInfoHeader({required this.hospital});

  @override
  Widget build(BuildContext context) {
    final h = hospital;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(h.name, style: AppTextStyles.heading2),
              ),
              const SizedBox(width: 8),
              _RatingBadge(rating: h.rating),
            ],
          ),
          const SizedBox(height: 8),
          _OpenBadge(isOpen: h.isOpen),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.location_on_rounded, text: h.address),
          if (h.phone?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.phone_rounded, text: h.phone!),
          ],
          if (h.workingHours?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.access_time_rounded, text: h.workingHours!),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.orange, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenBadge extends StatelessWidget {
  final bool isOpen;
  const _OpenBadge({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? AppColors.success.withOpacity(0.12)
            : AppColors.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isOpen ? AppColors.success : AppColors.error,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            isOpen ? 'Đang mở cửa' : 'Đã đóng cửa',
            style: TextStyle(
              color: isOpen ? AppColors.success : AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── tab 1: overview ────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final HospitalEntity hospital;

  const _OverviewTab({required this.hospital});

  @override
  Widget build(BuildContext context) {
    final h = hospital;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      children: [
        const Text('Giới thiệu', style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        Text(
          h.description?.isNotEmpty == true
              ? h.description!
              : 'Bệnh viện ${h.name} là một trong những cơ sở y tế hàng đầu, cung cấp các dịch vụ chăm sóc sức khỏe chất lượng cao cho cộng đồng.',
          style: AppTextStyles.body.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        const Text('Chuyên khoa', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: h.specialties.map((s) => _SpecialtyChip(label: s)).toList(),
        ),
        const SizedBox(height: 24),
        const Text('Liên hệ', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        if (h.phone?.isNotEmpty == true) ...[
          _ContactRow(icon: Icons.phone_rounded, label: h.phone!),
          const SizedBox(height: 8),
        ],
        // email and website fields are not in HospitalEntity but may appear from Firestore extra data
        if (h.workingHours?.isNotEmpty == true)
          _ContactRow(icon: Icons.access_time_rounded, label: h.workingHours!),
      ],
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  final String label;
  const _SpecialtyChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ContactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

// ─────────────────────────── tab 2: departments ─────────────────────────────

class _DepartmentsTab extends ConsumerWidget {
  final String hospitalId;

  const _DepartmentsTab({required this.hospitalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDepts = ref.watch(hospitalDepartmentsProvider(hospitalId));
    return asyncDepts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 40),
              const SizedBox(height: 12),
              Text('Không thể tải danh sách khoa.\n$e',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
      data: (depts) {
        if (depts.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.domain_disabled_rounded, color: AppColors.textHint, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Chưa có thông tin khoa phòng.',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          itemCount: depts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) => _DepartmentExpansionTile(
            hospitalId: hospitalId,
            department: depts[i],
          ),
        );
      },
    );
  }
}

// ─────────────────────────── expansion tile ─────────────────────────────────

class _DepartmentExpansionTile extends ConsumerWidget {
  final String hospitalId;
  final DepartmentEntity department;

  const _DepartmentExpansionTile({
    required this.hospitalId,
    required this.department,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.divider),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primarySurface,
          child: Icon(_deptIcon(department.iconName), color: AppColors.primary, size: 22),
        ),
        title: Text(department.name, style: AppTextStyles.subtitle),
        subtitle: department.doctorCount > 0
            ? Text(
                '${department.doctorCount} bác sĩ',
                style: AppTextStyles.bodySmall,
              )
            : null,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (department.description.isNotEmpty) ...[
            Text(
              department.description,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
          ],
          _DoctorSection(departmentId: department.id),
          const SizedBox(height: 16),
          _RoomsSection(
            hospitalId: hospitalId,
            deptId: department.id,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── doctor section ─────────────────────────────────

class _DoctorSection extends ConsumerWidget {
  final String departmentId;

  const _DoctorSection({required this.departmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDoctors = ref.watch(departmentDoctorsProvider(departmentId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bác sĩ', style: AppTextStyles.heading3),
        const SizedBox(height: 10),
        asyncDoctors.when(
          loading: () => const SizedBox(
            height: 90,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => Text(
            'Không thể tải danh sách bác sĩ.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
          data: (doctors) {
            if (doctors.isEmpty) {
              return Text(
                'Chưa có bác sĩ trong khoa này.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              );
            }
            return SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: doctors.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) => _DoctorCard(
                  doctor: doctors[i],
                  onTap: () => context.push(
                    '/doctor/detail/${doctors[i].id}',
                    extra: doctors[i],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorEntity doctor;
  final VoidCallback onTap;

  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.divider,
              backgroundImage: doctor.imageUrl.isNotEmpty
                  ? CachedNetworkImageProvider(doctor.imageUrl)
                  : null,
              child: doctor.imageUrl.isEmpty
                  ? const Icon(Icons.person_rounded, color: AppColors.textHint, size: 28)
                  : null,
            ),
            const SizedBox(height: 6),
            Text(
              doctor.name,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── rooms section ──────────────────────────────────

class _RoomsSection extends ConsumerWidget {
  final String hospitalId;
  final String deptId;

  const _RoomsSection({required this.hospitalId, required this.deptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = roomsProviderKey(hospitalId, deptId);
    final asyncRooms = ref.watch(departmentRoomsProvider(key));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Phòng khám', style: AppTextStyles.heading3),
        const SizedBox(height: 10),
        asyncRooms.when(
          loading: () => const SizedBox(
            height: 40,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (e, _) => Text(
            'Không thể tải danh sách phòng.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
          ),
          data: (rooms) {
            if (rooms.isEmpty) {
              return Text(
                'Chưa có thông tin phòng khám.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: rooms.map((room) => _RoomChip(room: room)).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _RoomChip extends StatelessWidget {
  final ClinicRoomEntity room;

  const _RoomChip({required this.room});

  @override
  Widget build(BuildContext context) {
    final color = _roomStatusColor(room.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            room.name,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (room.floor.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              room.floor,
              style: AppTextStyles.caption,
            ),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Text(
                _roomStatusLabel(room.status),
                style: AppTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
