import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import 'package:smart_clinic_booking/core/localization/app_language.dart';
import 'package:smart_clinic_booking/core/localization/language_controller.dart';
import 'package:smart_clinic_booking/features/auth/presentation/controllers/auth_controller.dart';
import 'package:smart_clinic_booking/features/notification/presentation/screens/notification_screen.dart';

// Theme Colors for ICARE - Re-matching to the screenshot branding
class _C {
  static const Color teal = Color(0xFF0288D1); // Use clinical blue for ICARE
  static const Color tealLight = Color(0xFFE1F5FE);
  static const Color textDark = Color(0xFF263238);
  static const Color textSub = Color(0xFF546E7A);
  static const Color card = Colors.white;
  static const Color rating = Color(0xFFFFB300);
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
  late AnimationController _pulseController;
  late PageController _bannerController;

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Navigation Helpers
  void _openBooking(BuildContext context) => context.push('/doctor/search');
  void _openDoctorSearch(BuildContext context) => context.push('/doctor/search');
  
  Future<void> _dialHotline() async {
    final uri = Uri(scheme: 'tel', path: '1900545454');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  // Logic Helpers
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = [
      _buildHomeContent(context, l10n),
      const NotificationScreen(),
      const Scaffold(body: Center(child: Text('Bản đồ phòng khám'))),
      _buildLanguageSelectionPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: pages[_tabIndex]),
      bottomNavigationBar: _buildBottomNav(l10n),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildPulsingFab(),
    );
  }

  Widget _buildHomeContent(BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context),
          _buildPersonalizedGreeting(l10n),
          _buildSearchBar(l10n),
          _buildBannerCarousel(),
          _buildFunctionalGrid(context, l10n),
          _buildHospitalIntro(l10n),
          _buildFeaturedFacilities(l10n),
          _buildCarePackages(l10n),
          _buildFeaturedDoctors(l10n),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: 40,
                errorBuilder: (c, e, s) => Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE3F2FD)),
                  child: const Icon(Icons.favorite_rounded, color: Color(0xFF0277BD), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'ICARE',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0277BD),
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'Healthcare Excellence',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF039BE5),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _topIconButton(Icons.notifications_none_rounded, () => setState(() => _tabIndex = 1)),
              const SizedBox(width: 10),
              _topIconButton(Icons.person_outline_rounded, () => context.push('/profile/patient')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedGreeting(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xin chào,',
            style: TextStyle(fontSize: 16, color: _C.textSub, fontWeight: FontWeight.w500),
          ),
          const Text(
            'Nhi Yến',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _C.textDark,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F9FD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.shade50),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: Colors.blue.shade300, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tìm CSYT/bác sĩ/chuyên khoa/dịch vụ',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Column(
      children: [
        Container(
          height: 180,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: PageView(
            controller: _bannerController,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            children: [
              _carouselItem('/Users/nguyenlephong/.gemini/antigravity/brain/70688c33-581e-4887-a639-0c9689e2c939/clinical_banner_1_1775891561919.png'),
              _carouselItem('/Users/nguyenlephong/.gemini/antigravity/brain/70688c33-581e-4887-a639-0c9689e2c939/clinical_banner_1_1775891561919.png'),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(2, (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _bannerIndex == index ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _bannerIndex == index ? _C.teal : Colors.blue.shade100,
            ),
          )),
        ),
      ],
    );
  }

  Widget _carouselItem(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildFunctionalGrid(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Chức năng',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF01579B),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.tune_rounded, color: Colors.blue.shade300, size: 20),
                  const SizedBox(width: 12),
                  Icon(Icons.search_rounded, color: Colors.blue.shade300, size: 20),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            mainAxisSpacing: 24,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: [
              _gridItem(Icons.add_task_rounded, 'Đặt khám', const Color(0xFF2196F3), () => _openBooking(context)),
              _gridItem(Icons.history_edu_rounded, 'Lịch sử khám', const Color(0xFF673AB7), () => context.push('/appointments')),
              _gridItem(Icons.account_balance_wallet_outlined, 'Thanh toán', const Color(0xFF00BFA5), () => {}),
              
              _gridItem(Icons.poll_outlined, 'Khảo sát', const Color(0xFFFF9800), () => {}),
              _gridItem(Icons.medication_liquid_rounded, 'Đơn thuốc', const Color(0xFFE91E63), () => context.push('/prescriptions')),
              _gridItem(Icons.hotel_rounded, 'Nhập viện', const Color(0xFF5D4037), () => {}),
              
              _gridItem(Icons.settings_suggest_outlined, 'Cài đặt TB', const Color(0xFF607D8B), () => {}),
              _gridItem(Icons.folder_shared_outlined, 'Hồ sơ', const Color(0xFF7B1FA2), () => context.push('/profile/patient')),
              _gridItem(Icons.vaccines_rounded, 'Tiêm chủng', const Color(0xFF43A047), () => {}),
              
              _gridItem(Icons.headset_mic_outlined, 'Hỗ trợ', const Color(0xFF0288D1), () => context.push('/support')),
              _gridItem(Icons.smart_toy_outlined, 'Chatbot', const Color(0xFFF4511E), () => context.push('/ai/voice-assistant')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.blue.shade50, width: 1),
        ),
        child: Icon(icon, color: const Color(0xFF0277BD), size: 24),
      ),
    );
  }

  Widget _gridItem(IconData icon, String label, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBFF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade50.withOpacity(0.3)),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF263238),
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulsingFab() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6A1B9A).withOpacity(0.8),
                const Color(0xFF4A148C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3 * (1 - _pulseController.value)),
                spreadRadius: 15 * _pulseController.value,
                blurRadius: 20 * _pulseController.value,
              ),
              BoxShadow(
                color: Colors.blue.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/ai/voice-assistant'),
              customBorder: const CircleBorder(),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 32),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (index) => setState(() => _tabIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF0277BD),
        unselectedItemColor: const Color(0xFF90A4AE),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Chào mừng'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none_rounded), label: 'Thông báo'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Bản đồ phòng k...'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Ngôn ngữ'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? subtitle, VoidCallback? onSeeAll, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: _C.textDark),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: _C.textSub),
                ),
            ],
          ),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: Text(
                l10n.patient_view_all,
                style: const TextStyle(color: _C.teal, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHospitalIntro(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, const Color(0xFF01579B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.patient_hospital_intro_title,
                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.patient_hospital_intro_desc,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF01579B),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(l10n.patient_see_more, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedFacilities(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 32),
        _buildSectionHeader(l10n.patient_section_facilities, l10n.patient_section_facilities_sub, () {}, l10n),
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _facilityCard(
                'Bệnh viện ĐH Y Dược',
                'Hồng Bàng, Quận 5',
                '4.8',
                'https://images.unsplash.com/photo-1587350859728-117699f4a13d?auto=format&fit=crop&q=80&w=400',
                l10n,
              ),
              _facilityCard(
                'Bệnh viện Hoàn Mỹ',
                'Phú Nhuận, TP.HCM',
                '4.7',
                'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&q=80&w=400',
                l10n,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _facilityCard(String name, String loc, String rating, String img, AppLocalizations l10n) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: CachedNetworkImage(
              imageUrl: img,
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade100, child: const Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => Container(
                color: _C.tealLight,
                child: const Icon(Icons.business_rounded, color: _C.teal, size: 40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: _C.teal),
                    const SizedBox(width: 4),
                    Text(loc, style: const TextStyle(fontSize: 12, color: _C.textSub)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 16, color: _C.rating),
                        Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _C.teal,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.patient_book_now,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarePackages(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 32),
        _buildSectionHeader(l10n.patient_section_care, l10n.patient_section_care_sub, () {}, l10n),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _filterChip(l10n.patient_tab_health, true),
              _filterChip(l10n.patient_tab_test, false),
              _filterChip(l10n.patient_tab_vaccine, false),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _packageCard('Gói khám tổng quát', '1.200.000đ', 'https://images.unsplash.com/photo-1576091160550-217359f42f8c?auto=format&fit=crop&q=80&w=400'),
              _packageCard('Gói khám tim mạch', '2.500.000đ', 'https://images.unsplash.com/photo-1628177142898-93e36e4e3a50?auto=format&fit=crop&q=80&w=400'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? _C.teal : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.white : _C.textSub,
          fontWeight: active ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _packageCard(String title, String price, String img) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: CachedNetworkImage(
              imageUrl: img,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey.shade100),
              errorWidget: (context, url, error) => Container(
                color: _C.tealLight,
                child: const Icon(Icons.medical_services_outlined, color: _C.teal, size: 30),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Text(price, style: const TextStyle(color: _C.teal, fontWeight: FontWeight.w900, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedDoctors(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: 32),
        _buildSectionHeader(l10n.patient_section_doctors, l10n.patient_section_doctors_sub, () {}, l10n),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _doctorAvatar('BS. Nguyễn Văn A', 'Khoa Nội', 'https://i.pravatar.cc/150?u=1'),
              _doctorAvatar('BS. Trần Thị B', 'Khoa Nhi', 'https://i.pravatar.cc/150?u=2'),
              _doctorAvatar('BS. Lê Văn C', 'Khoa Sản', 'https://i.pravatar.cc/150?u=3'),
              _doctorAvatar('BS. Phạm Thị D', 'Khoa Mắt', 'https://i.pravatar.cc/150?u=4'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _doctorAvatar(String name, String spec, String img) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: _C.tealLight),
            child: CircleAvatar(radius: 30, backgroundImage: NetworkImage(img)),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Text(spec, style: const TextStyle(fontSize: 10, color: _C.textSub)),
        ],
      ),
    );
  }

  Widget _buildLanguageSelectionPage() {
    return Consumer(builder: (context, ref, _) {
      final lang = ref.watch(languageControllerProvider);
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Chọn ngôn ngữ',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF01579B)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: AppLanguage.values.length,
              itemBuilder: (context, index) {
                final e = AppLanguage.values[index];
                final isSelected = e == lang;
                return ListTile(
                  leading: Text(e.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(e.languageName),
                  trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
                  tileColor: isSelected ? Colors.blue.withOpacity(0.05) : null,
                  onTap: () => ref.read(languageControllerProvider.notifier).setLanguage(e),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLanguageList() {
    return Consumer(builder: (context, ref, _) {
      final lang = ref.watch(languageControllerProvider);
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Chọn ngôn ngữ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF01579B)),
            ),
            const SizedBox(height: 16),
            ...AppLanguage.values.map((e) {
              final isSelected = e == lang;
              return ListTile(
                leading: Text(e.flag, style: const TextStyle(fontSize: 24)),
                title: Text(e.languageName),
                trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
                tileColor: isSelected ? Colors.blue.withOpacity(0.05) : null,
                onTap: () {
                  ref.read(languageControllerProvider.notifier).setLanguage(e);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ],
        ),
      );
    });
  }
}
