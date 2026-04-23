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

// ── Brand palette ────────────────────────────────────────────────────────────
class _P {
  static const Color primary = Color(0xFF0288D1);
  static const Color primaryDark = Color(0xFF01579B);
  static const Color accent = Color(0xFF00ACC1);
  static const Color surface = Color(0xFFF0F7FF);
  static const Color cardBg = Colors.white;
  static const Color textPrimary = Color(0xFF1A2B4A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFFB0BEC5);
  static const Color gold = Color(0xFFFFB300);
  static const Color success = Color(0xFF26A69A);
  static const Color warning = Color(0xFFF57C00);
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
      body: SafeArea(child: pages[_tabIndex]),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildPulsingFab(),
    );
  }

  Widget _buildPulsingFab() {
    return AnimatedBuilder(
      animation: _fabPulse,
      builder: (context, _) {
        return GestureDetector(
          onTap: () => context.push('/ai/voice-assistant'),
          child: Container(
            width: 64,
            height: 64,
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
                  spreadRadius: 12 * _fabPulse.value,
                  blurRadius: 20 * _fabPulse.value,
                ),
                const BoxShadow(
                  color: Color(0x557C3AED),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 30),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: _P.primary,
        unselectedItemColor: _P.textHint,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded),
                if (_unreadCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _unreadCount > 9 ? '9+' : '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
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
          _FeaturedDoctors(),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Logo + brand
          const ICareLogo(
            size: 40,
            showText: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $firstName',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _P.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'ICare Health',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: _P.primaryDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          // Notification icon
          _IconBtn(icon: Icons.notifications_outlined, onTap: onNotifTap),
          const SizedBox(width: 8),
          // Language selector
          const _LanguageBtn(),
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
                const Text('Chọn ngôn ngữ / Select Language', 
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _P.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune_rounded, color: _P.primary, size: 18),
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
      gradient: [const Color(0xFF0277BD), const Color(0xFF039BE5)],
      icon: Icons.calendar_month_rounded,
      title: lang.localize('Đặt lịch khám ngay', 'Book your appointment'),
      subtitle: lang.localize('Tìm bác sĩ nhanh chóng', 'Find a doctor in seconds'),
      action: lang.localize('Đặt khám', 'Book now'),
      route: '/doctor/search',
    ),
    _BannerData(
      gradient: [const Color(0xFF00838F), const Color(0xFF26C6DA)],
      icon: Icons.health_and_safety_rounded,
      title: lang.localize('Hồ sơ sức khỏe', 'Your health records'),
      subtitle: lang.localize('Truy cập mọi lúc mọi nơi', 'Access anytime, anywhere'),
      action: lang.localize('Xem hồ sơ', 'View records'),
      route: '/medical-records',
    ),
    _BannerData(
      gradient: [const Color(0xFF6A1B9A), const Color(0xFFAB47BC)],
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
          height: 160,
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
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: data.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: data.gradient.first.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4)),
                    ),
                    child: Text(
                      data.action,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(data.icon, color: Colors.white, size: 36),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick actions grid ───────────────────────────────────────────────────────
class _QuickActionsGrid extends ConsumerWidget {
  List<_Action> _getItems(AppLanguage lang) => [
    _Action(Icons.add_circle_outline_rounded, lang.localize('Đặt khám', 'Book Visit'), const Color(0xFF2196F3), '/doctor/search'),
    _Action(Icons.history_rounded, lang.localize('Lịch sử', 'History'), const Color(0xFF7C3AED), '/appointments'),
    _Action(Icons.receipt_long_rounded, lang.localize('Hóa đơn', 'Invoices'), const Color(0xFF00BFA5), '/invoices'),
    _Action(Icons.medication_rounded, lang.localize('Đơn thuốc', 'Prescription'), const Color(0xFFE91E63), '/prescriptions'),
    _Action(Icons.folder_open_rounded, lang.localize('Hồ sơ', 'Records'), const Color(0xFFFF6D00), '/medical-records'),
    _Action(Icons.local_hospital_rounded, lang.localize('Nhập viện', 'Admission'), const Color(0xFF5C6BC0), null),
    _Action(Icons.payments_outlined, lang.localize('Thanh toán', 'Payment'), const Color(0xFF43A047), '/payment'),
    _Action(Icons.poll_outlined, lang.localize('Khảo sát', 'Survey'), const Color(0xFFFB8C00), '/surveys'),
    _Action(Icons.headset_mic_rounded, lang.localize('Hỗ trợ', 'Support'), const Color(0xFF0288D1), '/support'),
    _Action(Icons.smart_toy_outlined, lang.localize('AI Chat', 'AI Chat'), const Color(0xFF6D4C41), '/ai/voice-assistant'),
    _Action(Icons.map_rounded, lang.localize('Bản đồ', 'Map'), const Color(0xFF00897B), '/maps'),
    _Action(Icons.newspaper_rounded, lang.localize('Tin tức', 'News'), const Color(0xFF757575), '/news'),
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
              const Icon(Icons.apps_rounded, color: _P.primary, size: 22),
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
            children: items
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
  const _Action(this.icon, this.label, this.color, this.route);
}

class _ActionCell extends StatelessWidget {
  final _Action item;
  const _ActionCell({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (item.route != null) {
          if (item.route == '/admission/registration/me') {
            final uid =
                FirebaseAuth.instance.currentUser?.uid ?? 'me';
            context.push('/admission/registration/$uid');
          } else {
            context.push(item.route!);
          }
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
            child: Icon(item.icon, color: item.color, size: 24),
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
class _UpcomingSection extends StatelessWidget {
  final List<_UpcomingAppt> appointments;
  final bool isLoading;

  const _UpcomingSection({
    required this.appointments,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Appointments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _P.primaryDark,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/appointments'),
                child: const Text(
                  'See all',
                  style: TextStyle(
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
          Text(
            lang.localize('Tổng quan sức khỏe', 'Health Overview'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _P.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.medication_outlined,
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
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
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
  static const _hospitals = [
    _HospitalData(
      name: 'ĐH Y Dược TPHCM',
      address: 'Quận 5, TP.HCM',
      rating: '4.8',
      imageUrl:
          'https://images.unsplash.com/photo-1587350859728-117699f4a13d?auto=format&fit=crop&q=80&w=400',
    ),
    _HospitalData(
      name: 'Bệnh viện Hoàn Mỹ',
      address: 'Phú Nhuận, TP.HCM',
      rating: '4.7',
      imageUrl:
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=400',
    ),
    _HospitalData(
      name: 'Bệnh viện Chợ Rẫy',
      address: 'Quận 5, TP.HCM',
      rating: '4.6',
      imageUrl:
          'https://images.unsplash.com/photo-1538108149393-fbbd81895907?auto=format&fit=crop&q=80&w=400',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageControllerProvider);
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
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _hospitals.length,
              itemBuilder: (context, i) =>
                  _HospitalCard(data: _hospitals[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HospitalData {
  final String name;
  final String address;
  final String rating;
  final String imageUrl;
  const _HospitalData({
    required this.name,
    required this.address,
    required this.rating,
    required this.imageUrl,
  });
}

class _HospitalCard extends StatelessWidget {
  final _HospitalData data;
  const _HospitalCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/doctor/search'),
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
                imageUrl: data.imageUrl,
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
                            data.rating,
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
                          'Book',
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
class _FeaturedDoctors extends StatefulWidget {
  @override
  State<_FeaturedDoctors> createState() => _FeaturedDoctorsState();
}

class _FeaturedDoctorsState extends State<_FeaturedDoctors> {
  List<Map<String, dynamic>> _doctors = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'doctor')
          .where('status', isEqualTo: 'active')
          .limit(6)
          .get();
      if (mounted) {
        setState(() {
          _doctors = snap.docs
              .map((d) => <String, dynamic>{
                    'id': d.id,
                    'name': d.data()['name'] ?? 'Doctor',
                    'specialty': d.data()['specialty'] ?? 'General',
                    'avatarUrl': d.data()['avatarUrl'] ?? '',
                  })
              .toList();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showFallback = _doctors.isEmpty && !_loading;
    final fallbackDoctors = [
      {'id': '1', 'name': 'Dr. Nguyen Van A', 'specialty': 'Cardiology', 'avatarUrl': 'https://i.pravatar.cc/150?u=d1'},
      {'id': '2', 'name': 'Dr. Tran Thi B', 'specialty': 'Pediatrics', 'avatarUrl': 'https://i.pravatar.cc/150?u=d2'},
      {'id': '3', 'name': 'Dr. Le Van C', 'specialty': 'Neurology', 'avatarUrl': 'https://i.pravatar.cc/150?u=d3'},
      {'id': '4', 'name': 'Dr. Pham Thi D', 'specialty': 'Ophthalmology', 'avatarUrl': 'https://i.pravatar.cc/150?u=d4'},
    ];
    final list = showFallback ? fallbackDoctors : _doctors;

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
                  'Featured Doctors',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _P.primaryDark,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/doctor/search'),
                  child: const Text(
                    'See all',
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
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: list.length,
                itemBuilder: (context, i) {
                  final doc = list[i];
                  return GestureDetector(
                    onTap: () => context.push(
                        '/doctor/detail/${doc['id']}'),
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: _P.primary.withOpacity(0.3),
                                  width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: _P.surface,
                              backgroundImage: (doc['avatarUrl'] as String).isNotEmpty
                                  ? NetworkImage(doc['avatarUrl'] as String)
                                  : null,
                              child: (doc['avatarUrl'] as String).isEmpty
                                  ? const Icon(
                                      Icons.person_rounded,
                                      color: _P.primary,
                                      size: 24)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (doc['name'] as String).split(' ').last,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _P.textPrimary,
                            ),
                          ),
                          Text(
                            doc['specialty'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: _P.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
