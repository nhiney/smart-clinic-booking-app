import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:smart_clinic_booking/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_clinic_booking/features/notification/presentation/screens/notification_screen.dart';
import 'package:smart_clinic_booking/features/maps/presentation/screens/hospital_map_screen.dart';
import 'package:smart_clinic_booking/features/profile/presentation/screens/patient_profile_screen.dart';
import 'package:smart_clinic_booking/core/localization/language_service.dart';
import 'package:smart_clinic_booking/core/localization/language_controller.dart';
import 'package:smart_clinic_booking/core/localization/app_language.dart';
import 'package:smart_clinic_booking/core/widgets/icare_logo.dart';
import 'package:smart_clinic_booking/features/content/presentation/controllers/content_controller.dart';
import 'package:smart_clinic_booking/features/home/domain/entities/health_article.dart';
import 'package:smart_clinic_booking/features/maps/presentation/controllers/hospital_map_controller.dart';
import 'package:smart_clinic_booking/features/maps/domain/entities/hospital_entity.dart';
import 'package:smart_clinic_booking/features/doctor/presentation/controllers/featured_doctors_provider.dart';
import 'package:smart_clinic_booking/features/doctor/domain/entities/doctor_entity.dart';
import 'package:intl/intl.dart';

// ── Brand palette ────────────────────────────────────────────────────────────
class _P {
  static const Color primary = Color(0xFF1D4ED8); // Deeper, more modern blue
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color accent = Color(0xFF3B82F6);
  static const Color surface = Color(0xFFF8FAFC); // Clean slate background
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint = Color(0xFF94A3B8);
  static const Color gold = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF97316);
}

// ── Upcoming appointment model (lightweight, no extra dependency) ─────────────
class _UpcomingAppt {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String status;

  const _UpcomingAppt({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.status,
  });
}

class PatientHomeScreen extends ConsumerStatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  ConsumerState<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends ConsumerState<PatientHomeScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  int _bannerIndex = 0;
  late AnimationController _fabPulse;
  late PageController _bannerCtrl;
  List<_UpcomingAppt> _upcomingAppts = [];
  bool _loadingAppts = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _bannerCtrl = PageController();
    _fabPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _loadUpcomingAppointments();
    _loadUnreadCount();
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    _fabPulse.dispose();
    super.dispose();
  }

  Future<void> _loadUpcomingAppointments() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _loadingAppts = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: uid)
          .where('status', whereIn: ['booked', 'confirmed', 'pending_booking'])
          .orderBy('dateTime')
          .limit(3)
          .get();
      final list = snap.docs.map((d) {
        final data = d.data();
        DateTime dt;
        try {
          dt = (data['dateTime'] as Timestamp).toDate();
        } catch (_) {
          dt = DateTime.now();
        }
        return _UpcomingAppt(
          id: d.id,
          doctorName: data['doctorName'] as String? ?? 'Unknown doctor',
          specialty: data['specialty'] as String? ?? '',
          dateTime: dt,
          status: data['status'] as String? ?? 'booked',
        );
      }).toList();
      if (mounted) setState(() => _upcomingAppts = list);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingAppts = false);
    }
  }

  Future<void> _loadUnreadCount() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();
      if (mounted) setState(() => _unreadCount = snap.docs.length);
    } catch (_) {}
  }

  String _greeting(AppLanguage currentLanguage) {
    final h = DateTime.now().hour;
    if (h < 12) return currentLanguage.localize('Chào buổi sáng', 'Good morning');
    if (h < 18) return currentLanguage.localize('Chào buổi chiều', 'Good afternoon');
    return currentLanguage.localize('Chào buổi tối', 'Good evening');
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = ref.watch(languageControllerProvider);
    final userName = context.watch<AuthController>().currentUser?.name ?? '';
    final firstName = userName.isNotEmpty ? userName.split(' ').last : currentLanguage.localize('bạn', 'there');

    final pages = [
      _HomeTab(
        firstName: firstName,
        greeting: _greeting(currentLanguage),
        bannerCtrl: _bannerCtrl,
        bannerIndex: _bannerIndex,
        onBannerChanged: (i) => setState(() => _bannerIndex = i),
        upcomingAppts: _upcomingAppts,
        loadingAppts: _loadingAppts,
        fabPulse: _fabPulse,
        onTabSwitch: (i) => setState(() => _tabIndex = i),
      ),
      const NotificationScreen(),
      const HospitalMapScreen(),
      const PatientProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: _P.surface,
      extendBody: true,
      body: SafeArea(child: pages[_tabIndex]),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildPulsingFab(),
    );
  }

  Widget _buildPulsingFab() {
    return Transform.translate(
      offset: const Offset(0, 14),
      child: AnimatedBuilder(
        animation: _fabPulse,
        builder: (context, _) {
          return GestureDetector(
            onTap: () => context.push('/ai/voice-assistant'),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED)
                        .withOpacity(0.35 * (1 - _fabPulse.value)),
                    spreadRadius: 10 * _fabPulse.value,
                    blurRadius: 18 * _fabPulse.value,
                  ),
                  const BoxShadow(
                    color: Color(0x447C3AED),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 24),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNav() {
    final lang = ref.watch(languageControllerProvider);
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Colors.white,
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(0, Icons.home_rounded, lang.localize('Trang chủ', 'Home')),
              _buildNavItem(1, Icons.notifications_none_rounded, lang.localize('Thông báo', 'Notifications'), showBadge: _unreadCount > 0),
              const SizedBox(width: 44), // Balanced gap for FAB
              _buildNavItem(2, Icons.map_rounded, lang.localize('Bản đồ', 'Map')),
              _buildNavItem(3, Icons.person_rounded, lang.localize('Cá nhân', 'Profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {bool showBadge = false}) {
    final isSelected = _tabIndex == index;
    return InkWell(
      onTap: () => setState(() => _tabIndex = index),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: isSelected ? _P.primary : _P.textHint,
                size: 24,
              ),
              if (showBadge)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: Text(
                      _unreadCount > 9 ? '9+' : '$_unreadCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? _P.primary : _P.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Home tab extracted to keep build clean ───────────────────────────────────
class _HomeTab extends StatelessWidget {
  final String firstName;
  final String greeting;
  final PageController bannerCtrl;
  final int bannerIndex;
  final ValueChanged<int> onBannerChanged;
  final List<_UpcomingAppt> upcomingAppts;
  final bool loadingAppts;
  final AnimationController fabPulse;
  final ValueChanged<int> onTabSwitch;

  const _HomeTab({
    required this.firstName,
    required this.greeting,
    required this.bannerCtrl,
    required this.bannerIndex,
    required this.onBannerChanged,
    required this.upcomingAppts,
    required this.loadingAppts,
    required this.fabPulse,
    required this.onTabSwitch,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(
            firstName: firstName,
            greeting: greeting,
            onNotifTap: () => onTabSwitch(1),
          ),
          _SearchBar(onTap: () => context.push('/doctor/search')),
          _BannerCarousel(
            ctrl: bannerCtrl,
            index: bannerIndex,
            onChanged: onBannerChanged,
          ),
          _QuickActionsGrid(),
          _UpcomingSection(
            appointments: upcomingAppts,
            isLoading: loadingAppts,
          ),
          _HealthStatsRow(),
          _FeaturedHospitals(),
          const _FeaturedDoctors(),
          _HealthNewsSection(),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String firstName;
  final String greeting;
  final VoidCallback onNotifTap;

  const _TopBar({
    required this.firstName,
    required this.greeting,
    required this.onNotifTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _P.primary.withOpacity(0.08),
            _P.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Logo + brand
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _P.primary.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const ICareLogo(
              size: 32,
              showText: false,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $firstName',
                  style: const TextStyle(
                    fontSize: 14,
                    color: _P.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'ICare Health',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _P.primaryDark,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          // Notification icon
          _IconBtn(
            icon: Icons.notifications_none_rounded,
            onTap: onNotifTap,
          ),
          const SizedBox(width: 8),
          _IconBtn(
            icon: Icons.person_outline_rounded,
            onTap: () => context.push('/profile/patient'),
          ),
        ],
      ),
    );
  }
}

class _LanguageBtn extends ConsumerWidget {
  const _LanguageBtn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageControllerProvider);
    
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Cài đặt ngôn ngữ', 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Text('🇻🇳', style: TextStyle(fontSize: 24)),
                  title: const Text('Tiếng Việt'),
                  selected: currentLanguage == AppLanguage.vi,
                  onTap: () {
                    ref.read(languageControllerProvider.notifier).setLanguage(AppLanguage.vi);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
                  title: const Text('English'),
                  selected: currentLanguage == AppLanguage.en,
                  onTap: () {
                    ref.read(languageControllerProvider.notifier).setLanguage(AppLanguage.en);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          currentLanguage == AppLanguage.vi ? '🇻🇳' : '🇺🇸',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: _P.primaryDark, size: 22),
      ),
    );
  }
}

// ── Search bar ───────────────────────────────────────────────────────────────
class _SearchBar extends ConsumerWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageControllerProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: _P.primary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lang.localize('Tìm bác sĩ, bệnh viện, chuyên khoa...', 'Search doctors, hospitals, specialties…'),
                  style: TextStyle(
                    color: _P.textHint,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Lọc tìm kiếm',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _P.primaryDark),
                          ),
                          const SizedBox(height: 20),
                          ListTile(
                            leading: const Icon(Icons.medical_services_outlined, color: _P.primary),
                            title: const Text('Bác sĩ chuyên khoa'),
                            onTap: () => Navigator.pop(context),
                          ),
                          ListTile(
                            leading: const Icon(Icons.local_hospital_outlined, color: _P.primary),
                            title: const Text('Bệnh viện / Phòng khám'),
                            onTap: () => Navigator.pop(context),
                          ),
                          ListTile(
                            leading: const Icon(Icons.history_edu_outlined, color: _P.primary),
                            title: const Text('Gói khám sức khỏe'),
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _P.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.tune_rounded, color: _P.primary, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Banner carousel ──────────────────────────────────────────────────────────
class _BannerCarousel extends ConsumerWidget {
  final PageController ctrl;
  final int index;
  final ValueChanged<int> onChanged;

  const _BannerCarousel({
    required this.ctrl,
    required this.index,
    required this.onChanged,
  });

  List<_BannerData> _getBanners(AppLanguage lang) => [
    _BannerData(
      gradient: [const Color(0xFF1565C0), const Color(0xFF1E88E5), const Color(0xFF42A5F5)],
      icon: Icons.calendar_month_rounded,
      title: lang.localize('Đặt lịch khám ngay', 'Book your appointment'),
      subtitle: lang.localize('Tìm bác sĩ nhanh chóng', 'Find a doctor in seconds'),
      action: lang.localize('Đặt khám', 'Book now'),
      route: '/doctor/search',
    ),
    _BannerData(
      gradient: [const Color(0xFF00695C), const Color(0xFF00897B), const Color(0xFF26A69A)],
      icon: Icons.health_and_safety_rounded,
      title: lang.localize('Hồ sơ sức khỏe', 'Your health records'),
      subtitle: lang.localize('Truy cập mọi lúc mọi nơi', 'Access anytime, anywhere'),
      action: lang.localize('Xem hồ sơ', 'View records'),
      route: '/medical-records',
    ),
    _BannerData(
      gradient: [const Color(0xFF4527A0), const Color(0xFF5E35B1), const Color(0xFF7E57C2)],
      icon: Icons.smart_toy_rounded,
      title: lang.localize('Trợ lý AI Y tế', 'AI Health Assistant'),
      subtitle: lang.localize('Hỏi đáp về sức khỏe của bạn', 'Ask anything about your health'),
      action: lang.localize('Thử ngay', 'Try now'),
      route: '/ai/voice-assistant',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageControllerProvider);
    final banners = _getBanners(lang);
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: ctrl,
            onPageChanged: onChanged,
            itemCount: banners.length,
            itemBuilder: (context, i) => _BannerCard(data: banners[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: index == i ? 20 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: index == i ? _P.primary : _P.textHint,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BannerData {
  final List<Color> gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final String route;

  const _BannerData({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.route,
  });
}

class _BannerCard extends StatelessWidget {
  final _BannerData data;
  const _BannerCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(data.route),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: data.gradient.first.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Background Gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: data.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              // Decorative Bubbles
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.12),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -40,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(22),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Premium Gradient Button
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.9),
                                    ],
                                  ),
                                ),
                                child: ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: data.gradient,
                                  ).createShader(bounds),
                                  child: Text(
                                    data.action,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Icon(data.icon, color: Colors.white, size: 36),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick actions grid ───────────────────────────────────────────────────────
class _QuickActionsGrid extends ConsumerWidget {
  List<_Action> _getItems(AppLanguage lang) => [
    _Action(Icons.add_circle_outline_rounded, lang.localize('Đặt khám', 'Book Visit'), const Color(0xFF2196F3), '/doctor/search', assetPath: 'assets/icons/quick_actions/book_appointment.png'),
    _Action(Icons.history_rounded, lang.localize('Lịch sử', 'History'), const Color(0xFF7C3AED), '/appointments', assetPath: 'assets/icons/quick_actions/appointment_history.png'),
    _Action(Icons.receipt_long_rounded, lang.localize('Hóa đơn', 'Invoices'), const Color(0xFF00BFA5), '/invoices', assetPath: 'assets/icons/quick_actions/invoice.png'),
    _Action(Icons.medication_rounded, lang.localize('Đơn thuốc', 'Prescription'), const Color(0xFFE91E63), '/prescriptions', assetPath: 'assets/icons/quick_actions/invoice.png'),
    _Action(Icons.folder_open_rounded, lang.localize('Hồ sơ', 'Records'), const Color(0xFFFF6D00), '/medical-records', assetPath: 'assets/icons/quick_actions/medical_records.png'),
    _Action(Icons.local_hospital_rounded, lang.localize('Nhập viện', 'Admission'), const Color(0xFF5C6BC0), '/admission/history/me', assetPath: 'assets/icons/quick_actions/inpatient_admission.png'),
    _Action(Icons.payments_outlined, lang.localize('Thanh toán', 'Payment'), const Color(0xFF43A047), '/payment', assetPath: 'assets/icons/quick_actions/fee_payment.png'),
    _Action(Icons.poll_outlined, lang.localize('Khảo sát', 'Survey'), const Color(0xFFFB8C00), '/surveys', assetPath: 'assets/icons/quick_actions/lab_results.png'),
    _Action(Icons.headset_mic_rounded, lang.localize('Hỗ trợ', 'Support'), const Color(0xFF0288D1), '/support', assetPath: 'assets/icons/quick_actions/customer_support.png'),
    _Action(Icons.smart_toy_outlined, lang.localize('AI Chat', 'AI Chat'), const Color(0xFF6D4C41), '/ai/voice-assistant', assetPath: 'assets/icons/quick_actions/chatbot.png'),
    _Action(Icons.map_rounded, lang.localize('Bản đồ', 'Map'), const Color(0xFF00897B), '/maps', assetPath: 'assets/icons/quick_actions/home_monitoring.png'),
    _Action(Icons.newspaper_rounded, lang.localize('Tin tức', 'News'), const Color(0xFF757575), '/news', assetPath: 'assets/icons/quick_actions/user_guide.png'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageControllerProvider);
    final items = _getItems(lang);
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: _P.cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lang.localize('Truy cập nhanh', 'Quick Access'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _P.primaryDark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Tất cả chức năng',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: _P.primaryDark,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(24),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: items.length,
                              itemBuilder: (context, index) => _ActionCell(item: items[index]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.more_horiz_rounded, color: _P.primary, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            mainAxisSpacing: 20,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
            children: items.take(8)
                .map((item) => _ActionCell(item: item))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _Action {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;
  final String? assetPath;
  const _Action(this.icon, this.label, this.color, this.route, {this.assetPath});
}

class _ActionCell extends StatelessWidget {
  final _Action item;
  const _ActionCell({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.route != null) {
          final uid = FirebaseAuth.instance.currentUser?.uid ?? 'me';
          final route = item.route!
              .replaceAll('/me', '/$uid');
          GoRouter.of(context).push(route);
        } else {
          GoRouter.of(context).push('/under-development?title=${Uri.encodeComponent(item.label)}');
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: item.assetPath != null 
              ? Image.asset(item.assetPath!, width: 24, height: 24, fit: BoxFit.contain)
              : Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _P.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upcoming appointments ────────────────────────────────────────────────────
class _UpcomingSection extends ConsumerWidget {
  final List<_UpcomingAppt> appointments;
  final bool isLoading;

  const _UpcomingSection({
    required this.appointments,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageControllerProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lang.localize('Lịch khám sắp tới', 'Upcoming Appointments'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _P.primaryDark,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/appointments'),
                child: Text(
                  lang.localize('Xem tất cả', 'See all'),
                  style: const TextStyle(
                    color: _P.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (appointments.isEmpty)
            _EmptyAppt()
          else
            ...appointments.map((a) => _ApptCard(appt: a)),
        ],
      ),
    );
  }
}

class _EmptyAppt extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageControllerProvider);
    return GestureDetector(
      onTap: () => context.push('/doctor/search'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _P.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _P.primary.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(Icons.event_available_rounded,
                color: _P.primary.withOpacity(0.5), size: 40),
            const SizedBox(height: 12),
            Text(
              lang.localize('Không có lịch khám sắp tới', 'No upcoming appointments'),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: _P.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              lang.localize('Nhấn để đặt lịch khám đầu tiên', 'Tap to book your first appointment'),
              style: const TextStyle(fontSize: 13, color: _P.textHint),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApptCard extends ConsumerWidget {
  final _UpcomingAppt appt;
  const _ApptCard({required this.appt});

  Color get _statusColor {
    switch (appt.status) {
      case 'confirmed':
        return _P.success;
      case 'booked':
        return _P.primary;
      default:
        return _P.warning;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageControllerProvider);
    final day = appt.dateTime.day.toString().padLeft(2, '0');
    final month = _month(appt.dateTime.month, lang);
    final time =
        '${appt.dateTime.hour.toString().padLeft(2, '0')}:${appt.dateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _P.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date block
          Container(
            width: 52,
            height: 56,
            decoration: BoxDecoration(
              color: _P.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _P.primary,
                    height: 1,
                  ),
                ),
                Text(
                  month,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _P.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appt.doctorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: _P.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  appt.specialty.isEmpty ? lang.localize('Tổng quát', 'General') : appt.specialty,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _P.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: _P.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _translateStatus(appt.status, lang),
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _translateStatus(String status, AppLanguage lang) {
    switch (status) {
      case 'confirmed': return lang.localize('Đã xác nhận', 'Confirmed');
      case 'booked': return lang.localize('Đã đặt', 'Booked');
      case 'pending': return lang.localize('Chờ duyệt', 'Pending');
      default: return status.replaceAll('_', ' ');
    }
  }

  String _month(int m, AppLanguage lang) {
    if (lang == AppLanguage.vi) return 'Thg $m';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m - 1];
  }
}

// ── Health stats row ─────────────────────────────────────────────────────────
class _HealthStatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageControllerProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: _P.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                lang.localize('Tổng quan sức khỏe', 'Health Overview'),
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: _P.primaryDark,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.medication_outlined,
                  assetPath: 'assets/icons/quick_actions/invoice.png',
                  color: const Color(0xFFE91E63),
                  title: lang.localize('Đơn thuốc', 'Medications'),
                  subtitle: lang.localize('Nhấn để xem', 'Tap to view'),
                  onTap: () => context.push('/prescriptions'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.folder_shared_rounded,
                  assetPath: 'assets/icons/quick_actions/medical_records.png',
                  color: const Color(0xFF7C3AED),
                  title: lang.localize('Hồ sơ', 'Records'),
                  subtitle: lang.localize('Nhấn để xem', 'Tap to view'),
                  onTap: () => context.push('/medical-records'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.receipt_long_rounded,
                  assetPath: 'assets/icons/quick_actions/invoice.png',
                  color: const Color(0xFF00897B),
                  title: lang.localize('Hóa đơn', 'Invoices'),
                  subtitle: lang.localize('Nhấn để xem', 'Tap to view'),
                  onTap: () => context.push('/invoices'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String? assetPath;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    this.assetPath,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _P.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.12),
                    color.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: assetPath != null
                  ? Image.asset(assetPath!, width: 26, height: 26)
                  : Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _P.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: _P.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Featured hospitals ────────────────────────────────────────────────────────
class _FeaturedHospitals extends ConsumerWidget {
  const _FeaturedHospitals();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageControllerProvider);
    final hospitalsAsync = ref.watch(featuredHospitalsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang.localize('Bệnh viện nổi bật', 'Featured Hospitals'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _P.primaryDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/maps'),
                  child: Text(
                    lang.localize('Xem tất cả', 'See all'),
                    style: const TextStyle(
                      color: _P.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          hospitalsAsync.when(
            loading: () => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Lỗi tải bệnh viện: $error',
                        style: const TextStyle(fontSize: 12, color: _P.textSecondary),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => ref.refresh(featuredHospitalsProvider),
                      child: const Icon(Icons.refresh_rounded, color: _P.primary, size: 20),
                    ),
                  ],
                ),
              ),
            ),
            data: (hospitals) {
              if (hospitals.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _P.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_hospital_outlined,
                            color: _P.primary.withOpacity(0.5), size: 20),
                        const SizedBox(width: 10),
                        Text(
                          lang.localize(
                            'Chưa có dữ liệu bệnh viện',
                            'No hospital data yet',
                          ),
                          style: const TextStyle(color: _P.textSecondary, fontSize: 13),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => ref.refresh(featuredHospitalsProvider),
                          child: const Icon(Icons.refresh_rounded, color: _P.primary, size: 20),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: hospitals.length,
                  itemBuilder: (context, i) => _HospitalCard(data: hospitals[i]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final HospitalEntity data;
  const _HospitalCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final defaultImage = 'https://images.unsplash.com/photo-1587350859728-117699f4a13d?auto=format&fit=crop&q=80&w=400';
    
    return GestureDetector(
      onTap: () => context.push('/hospital/detail/${data.id}', extra: data),
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: _P.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: data.imageUrl?.isNotEmpty == true ? data.imageUrl! : defaultImage,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: _P.surface,
                  child: const Center(
                    child: Icon(Icons.local_hospital_rounded,
                        color: _P.primary, size: 32),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: _P.surface,
                  child: const Center(
                    child: Icon(Icons.local_hospital_rounded,
                        color: _P.primary, size: 32),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _P.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded,
                          size: 13, color: _P.primary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          data.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: _P.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: _P.gold),
                          const SizedBox(width: 3),
                          Text(
                            data.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _P.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Đặt lịch',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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
}

// ── Featured doctors ─────────────────────────────────────────────────────────
class _FeaturedDoctors extends ConsumerWidget {
  const _FeaturedDoctors();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(featuredDoctorsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bác sĩ nổi bật',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _P.primaryDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/doctor/search'),
                  child: const Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: _P.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          doctorsAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (doctors) {
              if (doctors.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: doctors.length,
                  itemBuilder: (context, i) =>
                      _FeaturedDoctorItem(doctor: doctors[i]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FeaturedDoctorItem extends StatelessWidget {
  final DoctorEntity doctor;
  const _FeaturedDoctorItem({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/doctor/detail/${doctor.id}', extra: doctor),
      child: Container(
        width: 96,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _P.primary.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: _P.surface,
              backgroundImage: doctor.imageUrl.isNotEmpty
                  ? NetworkImage(doctor.imageUrl)
                  : null,
              child: doctor.imageUrl.isEmpty
                  ? const Icon(Icons.person_rounded, color: _P.primary, size: 24)
                  : null,
            ),
            const SizedBox(height: 7),
            Text(
              doctor.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _P.textPrimary,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              doctor.specialty,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: _P.primary.withValues(alpha: 0.85),
              ),
            ),
            if (doctor.rating > 0) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, size: 11, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(
                    doctor.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _P.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Health news section ──────────────────────────────────────────────────────
class _HealthNewsSection extends ConsumerStatefulWidget {
  const _HealthNewsSection();
  @override
  ConsumerState<_HealthNewsSection> createState() => _HealthNewsSectionState();
}

class _HealthNewsSectionState extends ConsumerState<_HealthNewsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(newsProvider.notifier).loadNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageControllerProvider);
    final newsState = ref.watch(newsProvider);
    final articles = newsState.articles.take(5).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang.localize('Tin tức y tế', 'Health News'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _P.primaryDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/news'),
                  child: Text(
                    lang.localize('Xem tất cả', 'See all'),
                    style: const TextStyle(
                      color: _P.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (newsState.isLoading && articles.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (articles.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Center(
                  child: Text(
                    lang.localize('Không có tin tức nào', 'No news available'),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: articles.length,
                itemBuilder: (context, i) => _NewsCard(article: articles[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _NewsCard extends ConsumerWidget {
  final HealthArticle article;
  const _NewsCard({required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageControllerProvider);
    return GestureDetector(
      onTap: () {
        context.push('/news'); 
      },
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: CachedNetworkImage(
                imageUrl: article.imageUrl ?? '',
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: const Color(0xFFF0F7FF),
                  child: const Center(
                    child: Icon(Icons.newspaper_rounded, color: Color(0xFF0288D1), size: 30),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: const Color(0xFFF0F7FF),
                  child: const Center(
                    child: Icon(Icons.newspaper_rounded, color: Color(0xFF0288D1), size: 30),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.source,
                    style: const TextStyle(
                      color: Color(0xFF0288D1),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF1A2B4A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(article.publishedAt, lang),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt, AppLanguage lang) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) {
      return lang == AppLanguage.vi ? '${diff.inDays} ngày trước' : '${diff.inDays} days ago';
    }
    if (diff.inHours > 0) {
      return lang == AppLanguage.vi ? '${diff.inHours} giờ trước' : '${diff.inHours} hours ago';
    }
    if (diff.inMinutes > 0) {
      return lang == AppLanguage.vi ? '${diff.inMinutes} phút trước' : '${diff.inMinutes} mins ago';
    }
    return lang == AppLanguage.vi ? 'Vừa xong' : 'Just now';
  }
}
