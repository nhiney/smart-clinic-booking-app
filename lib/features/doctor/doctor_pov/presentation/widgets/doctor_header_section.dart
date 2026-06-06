import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_clinic_booking/features/doctor/patient_pov/presentation/controllers/doctor_controller.dart';
import 'package:smart_clinic_booking/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_clinic_booking/core/extensions/context_extension.dart';

class DoctorHeaderSection extends StatelessWidget {
  const DoctorHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DoctorController>();
    final doctor = controller.currentDoctor;
    final now = TimeOfDay.now();
    final hour = now.hour;
    final greeting = hour < 12 ? 'Chào buổi sáng' : hour < 18 ? 'Chào buổi chiều' : 'Chào buổi tối';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.spacing.m),
      child: Row(
        children: [
          // Avatar → tap opens profile
          GestureDetector(
            onTap: () => context.push('/doctor/profile'),
            child: _DoctorAvatar(imageUrl: doctor?.imageUrl ?? '', name: doctor?.name ?? ''),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      doctor?.specialty.isNotEmpty == true ? doctor!.specialty.toUpperCase() : 'BÁC SĨ',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.colors.primary, letterSpacing: 0.5),
                    ),
                  ),
                ]),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => context.push('/doctor/profile'),
                  child: Text(
                    doctor?.name ?? 'Bác sĩ',
                    style: context.textStyles.heading2.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$greeting',
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          Stack(children: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: context.colors.textSecondary),
              onPressed: () {},
            ),
            Positioned(right: 8, top: 8,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                child: const Center(child: Text('5', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700))),
              )),
          ]),
          // Menu → profile + logout
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: context.colors.textSecondary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            offset: const Offset(0, 40),
            onSelected: (val) async {
              if (val == 'profile') {
                context.push('/doctor/profile');
              } else if (val == 'logout') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.w700)),
                    content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<AuthController>().logout();
                  if (context.mounted) context.go('/login');
                }
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'profile',
                child: Row(children: [
                  Icon(Icons.person_rounded, size: 18, color: Color(0xFF1D4ED8)),
                  SizedBox(width: 10),
                  Text('Hồ sơ bác sĩ', style: TextStyle(fontWeight: FontWeight.w600)),
                ])),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout_rounded, size: 18, color: Color(0xFFEF4444)),
                  SizedBox(width: 10),
                  Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                ])),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoctorAvatar extends StatelessWidget {
  final String imageUrl;
  final String name;
  const _DoctorAvatar({required this.imageUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.split(' ').where((p) => p.isNotEmpty).take(2).map((p) => p[0]).join();
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.primary.withValues(alpha: 0.3), width: 2),
          ),
          child: ClipOval(
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _Initials(initials: initials),
                  )
                : _Initials(initials: initials),
          ),
        ),
        Positioned(
          bottom: 2,
          right: 2,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _Initials extends StatelessWidget {
  final String initials;
  const _Initials({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.primary.withValues(alpha: 0.12),
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            color: context.colors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
