import 'package:flutter/material.dart';
import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import 'package:smart_clinic_booking/features/booking/presentation/screens/booking_screen.dart';
import 'package:smart_clinic_booking/features/doctor/presentation/screens/doctor_search_screen.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(context, l10n)),
                  SliverToBoxAdapter(child: _buildBannerCarousel(l10n)),
                  SliverToBoxAdapter(child: _buildQuickActions(context, l10n)),
                  SliverToBoxAdapter(child: _buildSectionTitle(l10n.patient_section_facilities, l10n.patient_section_facilities_sub, l10n)),
                  SliverToBoxAdapter(child: _buildHospitalCards()),
                  SliverToBoxAdapter(child: _buildSectionTitle(l10n.patient_section_doctors, l10n.patient_section_doctors_sub, l10n)),
                  SliverToBoxAdapter(child: _buildDoctorCards()),
                  SliverToBoxAdapter(child: _buildSectionTitle(l10n.patient_section_care, l10n.patient_section_care_sub, l10n)),
                  SliverToBoxAdapter(child: _buildCareTabs(l10n)),
                  SliverToBoxAdapter(child: _buildCareCards()),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.orange,
        child: const Icon(Icons.call_rounded, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: const Color(0xFF1BAFE9),
        unselectedItemColor: Colors.black54,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_rounded), label: l10n.nav_home),
          BottomNavigationBarItem(icon: const Icon(Icons.folder_shared_outlined), label: l10n.nav_medical_record),
          BottomNavigationBarItem(icon: const Icon(Icons.receipt_long_outlined), label: l10n.nav_schedule),
          BottomNavigationBarItem(icon: const Icon(Icons.notifications_none_rounded), label: l10n.notification_title),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline_rounded), label: l10n.nav_profile),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      decoration: const BoxDecoration(
        color: Color(0xFFB8E0FF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.8),
                child: const Icon(Icons.health_and_safety_rounded, color: Color(0xFF1BAFE9)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.patient_header_greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF123B5D),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF22B8C8)),
                ),
                child: const Text(
                  'Tất cả/VI',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: l10n.patient_search_hint,
              hintStyle: const TextStyle(fontSize: 14),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              suffixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel(AppLocalizations l10n) {
    return SizedBox(
      height: 160,
      child: ListView(
        padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
        scrollDirection: Axis.horizontal,
        children: [
          _BannerCard(title: l10n.patient_banner_online_consult),
          const SizedBox(width: 10),
          _BannerCard(title: l10n.patient_banner_personal_assistant),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    final items = [
      ('Tìm kiếm & Khám bệnh', Icons.manage_search_rounded),
      ('Đặt lịch khám', Icons.event_available_rounded),
      (l10n.patient_action_book_facility, Icons.calendar_month_rounded),
      (l10n.patient_action_book_specialty, Icons.medical_services_rounded),
      (l10n.patient_action_book_test, Icons.vaccines_rounded),
      (l10n.patient_action_health_package, Icons.health_and_safety_rounded),
      (l10n.patient_action_personal_assistant, Icons.elderly_rounded),
      (l10n.patient_action_video_call, Icons.video_call_rounded),
      (l10n.patient_action_buy_medicine, Icons.medication_liquid_rounded),
      (l10n.patient_action_corporate_checkup, Icons.shield_rounded),
    ];

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.85,
          mainAxisSpacing: 10,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (_, i) => InkWell(
          onTap: () {
            if (i == 0) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DoctorSearchScreen(),
                ),
              );
            } else if (i == 1) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const BookingScreen(),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE6F7FF),
                child: Icon(items[i].$2, size: 18, color: const Color(0xFF1BAFE9)),
              ),
              const SizedBox(height: 6),
              Text(
                items[i].$1,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 33, fontWeight: FontWeight.w800, color: Color(0xFF113C5E)),
                ),
                Text(subtitle, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Text(
            l10n.patient_view_all,
            style: const TextStyle(color: Color(0xFF1BAFE9), fontWeight: FontWeight.w600, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCards() {
    return SizedBox(
      height: 240,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: const [
          _InfoCard(title: 'Bệnh viện Đại học Y Dược TP.HCM', subtitle: 'Q.5, TP.HCM', price: '4.7 ★'),
          SizedBox(width: 10),
          _InfoCard(title: 'Bệnh viện Đa khoa Hoàn Mỹ Cửu Long', subtitle: 'Cần Thơ', price: '5 ★'),
        ],
      ),
    );
  }

  Widget _buildDoctorCards() {
    return SizedBox(
      height: 240,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: const [
          _InfoCard(title: 'BS CKII. Ngô Trung Nam', subtitle: 'Sản phụ khoa', price: '200.000đ'),
          SizedBox(width: 10),
          _InfoCard(title: 'BS. Lê Tuấn', subtitle: 'Nội khoa', price: '150.000đ'),
        ],
      ),
    );
  }

  Widget _buildCareTabs(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _ChipTab(text: l10n.patient_tab_health, active: true),
          const SizedBox(width: 8),
          _ChipTab(text: l10n.patient_tab_test),
          const SizedBox(width: 8),
          _ChipTab(text: l10n.patient_tab_vaccine),
        ],
      ),
    );
  }

  Widget _buildCareCards() {
    return SizedBox(
      height: 250,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
        scrollDirection: Axis.horizontal,
        children: const [
          _InfoCard(title: 'Gói khám mắt tổng quát', subtitle: 'Trung Tâm Mắt Quốc Tế', price: '500.000đ'),
          SizedBox(width: 10),
          _InfoCard(title: 'Gói khám tiểu đường', subtitle: 'PK Đa khoa Quốc tế', price: '720.000đ'),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final String title;
  const _BannerCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF6ED1FF), Color(0xFF2BA8F5)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const Expanded(
              child: Icon(Icons.medical_information_rounded, color: Colors.white, size: 56),
            ),
            Expanded(
              flex: 2,
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 26, height: 1.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  const _InfoCard({required this.title, required this.subtitle, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 95,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Icons.local_hospital_rounded, size: 42, color: Color(0xFF1BAFE9)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(subtitle, style: const TextStyle(fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(price, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFDAA520), fontSize: 17)),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1BAFE9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  AppLocalizations.of(context)!.patient_book_now,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipTab extends StatelessWidget {
  final String text;
  final bool active;
  const _ChipTab({required this.text, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF1BAFE9) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF1BAFE9),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
