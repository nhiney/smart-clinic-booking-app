import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../../core/extensions/context_extension.dart';
import '../../../../appointment/domain/entities/appointment_entity.dart';
import '../../../../appointment/presentation/screens/appointment_history_screen.dart';
import '../../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../medical_record/presentation/screens/medical_record_screen.dart';
import '../controllers/doctor_controller.dart';

import 'package:smart_clinic_booking/l10n/app_localizations.dart';
import 'doctor_auxiliary_screens.dart';
import 'doctor_examine_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

enum _DoctorQuickAction { schedule, appointmentsToday, examine, medicalRecord, videoCall, chat }

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthController>().currentUser;
      if (user != null) {
        context.read<DoctorController>().fetchDoctorProfile(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<DoctorController>();
    final doctor = controller.currentDoctor;

    if (controller.isLoading && doctor == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          sizing: StackFit.expand,
          children: [
            RefreshIndicator(
              onRefresh: () async {
                final user = context.read<AuthController>().currentUser;
                if (user != null) {
                  await controller.fetchDoctorProfile(user.id);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, doctor, l10n),
                    const SizedBox(height: 24),
                    _buildSummary(context, controller, l10n),
                    const SizedBox(height: 24),
                    _buildQuickActions(context, l10n),
                    const SizedBox(height: 24),
                    _buildWorkloadManagement(context, controller, l10n),
                    const SizedBox(height: 24),
                    _buildTodaySchedule(context, controller, l10n),
                    const SizedBox(height: 24),
                    _buildMedicalRecordForm(context, l10n),
                    const SizedBox(height: 24),
                    _buildAdvancedFeatures(context, l10n),
                  ],
                ),
              ),
            ),
            const AppointmentHistoryScreen(),
            const MedicalRecordScreen(),
            const DoctorProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  void _onQuickAction(BuildContext context, _DoctorQuickAction action) {
    switch (action) {
      case _DoctorQuickAction.schedule:
      case _DoctorQuickAction.appointmentsToday:
        setState(() => _currentIndex = 1);
        break;
      case _DoctorQuickAction.examine:
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => const DoctorExamineScreen()),
        );
        break;
      case _DoctorQuickAction.medicalRecord:
        setState(() => _currentIndex = 2);
        break;
      case _DoctorQuickAction.videoCall:
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => const DoctorVideoConsultScreen()),
        );
        break;
      case _DoctorQuickAction.chat:
        context.push('/support/chatbot');
        break;
    }
  }

  void _openExamineForAppointment(BuildContext context, AppointmentEntity apt) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => DoctorExamineScreen(appointment: apt)),
    );
  }

  // 1. HEADER
  Widget _buildHeader(BuildContext context, dynamic doctor, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.doctor_greeting} 👋',
                  style: context.textStyles.bodySmall.copyWith(color: context.colors.textHint),
                ),
                Text(
                  doctor?.name ?? 'Dr. Nguyễn Văn An',
                  style: context.textStyles.heading2.copyWith(color: context.colors.primary),
                ),
                Text(
                  '${doctor?.specialty ?? "Nội tổng quát"} • ${doctor?.hospital ?? "Bệnh viện Chợ Rẫy"}',
                  style: context.textStyles.body.copyWith(color: context.colors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => setState(() => _currentIndex = 3),
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.colors.primary.withOpacity(0.2), width: 3),
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?u=doctor'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. DASHBOARD SUMMARY
  Widget _buildSummary(BuildContext context, DoctorController controller, AppLocalizations l10n) {
    final stats = controller.stats;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(l10n.doctor_today_stats, style: context.textStyles.heading3),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 108,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildStatCard(context, l10n.doctor_patients_today, stats['today_total'].toString(), Icons.people_outline, Colors.blue,
                  onTap: () => setState(() => _currentIndex = 1)),
              _buildStatCard(context, l10n.doctor_appointments_today, stats['confirmed'].toString(), Icons.calendar_today_outlined, Colors.orange,
                  onTap: () => setState(() => _currentIndex = 1)),
              _buildStatCard(context, l10n.doctor_waiting, stats['waiting'].toString(), Icons.hourglass_empty_rounded, Colors.green,
                  onTap: () => setState(() => _currentIndex = 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 156,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(value, style: context.textStyles.heading1.copyWith(color: color, fontSize: 22)),
            ],
          ),
        ),
      ),
    );
  }

  // 3. QUICK ACTIONS (GRID)
  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    final actions = <({_DoctorQuickAction id, String title, IconData icon, Color color})>[
      (id: _DoctorQuickAction.schedule, title: l10n.nav_schedule, icon: Icons.event_note_rounded, color: Colors.blue),
      (id: _DoctorQuickAction.appointmentsToday, title: l10n.doctor_appointments_today, icon: Icons.verified_user_outlined, color: Colors.teal),
      (id: _DoctorQuickAction.examine, title: l10n.doctor_button_examine, icon: Icons.medical_services_outlined, color: Colors.redAccent),
      (id: _DoctorQuickAction.medicalRecord, title: l10n.nav_medical_record, icon: Icons.contact_page_outlined, color: Colors.purple),
      (id: _DoctorQuickAction.videoCall, title: 'Video call', icon: Icons.video_call_outlined, color: Colors.indigo),
      (id: _DoctorQuickAction.chat, title: 'Chat', icon: Icons.chat_bubble_outline_rounded, color: Colors.blueGrey),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.doctor_quick_actions, style: context.textStyles.heading3),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return InkWell(
                onTap: () => _onQuickAction(context, action.id),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(action.icon, color: action.color, size: 30),
                      const SizedBox(height: 8),
                      Text(
                        action.title,
                        textAlign: TextAlign.center,
                        style: context.textStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 4. TODAY SCHEDULE
  Widget _buildTodaySchedule(BuildContext context, DoctorController controller, AppLocalizations l10n) {
    if (controller.todayAppointments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.doctor_today_schedule, style: context.textStyles.heading3),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border.withAlpha(20)),
              ),
              child: Center(child: Text(l10n.doctor_no_appointments_today)),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.doctor_today_schedule, style: context.textStyles.heading3),
              TextButton(onPressed: () => setState(() => _currentIndex = 1), child: Text(l10n.doctor_view_all)),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.todayAppointments.length,
            itemBuilder: (context, index) {
              final apt = controller.todayAppointments[index];
              return _buildAppointmentItem(context, apt);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentItem(BuildContext context, AppointmentEntity apt) {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor = Colors.orange;
    if (apt.status == AppointmentStatuses.confirmed) statusColor = Colors.green;
    if (apt.status == AppointmentStatuses.inQueue) statusColor = Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('HH:mm').format(apt.dateTime),
                  style: context.textStyles.bodyBold.copyWith(color: context.colors.primary),
                ),
                Text(l10n.doctor_morning, style: context.textStyles.bodySmall.copyWith(fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(apt.patientName, style: context.textStyles.bodyBold),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(apt.status.replaceAll('_', ' ').toUpperCase(), 
                         style: context.textStyles.bodySmall.copyWith(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _openExamineForAppointment(context, apt),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(l10n.doctor_button_examine),
          ),
        ],
      ),
    );
  }

  // 5. MEDICAL RECORD (BỆNH ÁN)
  Widget _buildMedicalRecordForm(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.doctor_medical_record, style: context.textStyles.heading3),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.border.withAlpha(20)),
            ),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: '${l10n.doctor_diagnosis}...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: context.colors.background,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(context, Icons.draw, l10n.doctor_sign, Colors.blue),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(context, Icons.send, l10n.doctor_send_prescription, Colors.green),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildActionButton(context, Icons.upload_file, l10n.doctor_upload_results, Colors.orange),
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

  Widget _buildActionButton(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label, style: context.textStyles.bodySmall.copyWith(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  // 6. ADVANCED FEATURES
  Widget _buildAdvancedFeatures(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.doctor_advanced_features, style: context.textStyles.heading3),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAdvancedCard(
                  context,
                  'AI Diagnosis',
                  l10n.doctor_ai_support,
                  Icons.auto_awesome,
                  Colors.deepPurple,
                  onTap: () => context.push('/ai/voice-assistant'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAdvancedCard(
                  context,
                  'Patient Ratings',
                  l10n.doctor_patient_rating,
                  Icons.star_rounded,
                  Colors.amber,
                  onTap: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(builder: (_) => const DoctorPatientRatingsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 12),
              Text(title, style: context.textStyles.bodyBold.copyWith(color: Colors.white)),
              const SizedBox(height: 4),
              Text(subtitle, style: context.textStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.9), fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  // 7. WORKLOAD MANAGEMENT
  Widget _buildWorkloadManagement(BuildContext context, DoctorController controller, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.primary.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.doctor_workload_management, style: context.textStyles.bodyBold),
                Text('75%', style: context.textStyles.bodyBold.copyWith(color: context.colors.primary)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                value: 0.75,
                minHeight: 10,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: _buildWorkloadItem(context, '${l10n.doctor_workload_limit}: 40')),
                Expanded(child: _buildWorkloadItem(context, '${l10n.doctor_workload_done}: 30')),
                Expanded(child: _buildWorkloadItem(context, '${l10n.doctor_workload_break}: 12:00')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkloadItem(BuildContext context, String label) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, size: 14, color: context.colors.primary),
        const SizedBox(width: 4),
        Text(label, style: context.textStyles.bodySmall.copyWith(fontSize: 11)),
      ],
    );
  }

  // 8. BOTTOM NAVIGATION
  Widget _buildBottomNav(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: context.colors.primary,
      unselectedItemColor: context.colors.textHint,
      showUnselectedLabels: true,
      selectedFontSize: 10,
      unselectedFontSize: 9,
      items: [
        BottomNavigationBarItem(icon: const Icon(Icons.home_filled), label: l10n.nav_home),
        BottomNavigationBarItem(icon: const Icon(Icons.calendar_month_rounded), label: l10n.nav_schedule),
        BottomNavigationBarItem(icon: const Icon(Icons.assignment_rounded), label: l10n.nav_medical_record),
        BottomNavigationBarItem(icon: const Icon(Icons.person_rounded), label: l10n.nav_profile),
      ],
    );
  }
}
