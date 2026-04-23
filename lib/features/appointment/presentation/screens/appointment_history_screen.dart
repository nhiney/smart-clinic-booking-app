import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../shared/widgets/appointment_card.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../controllers/appointment_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/widgets/branded_app_bar.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() =>
      _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      if (auth.currentUser != null) {
        context
            .read<AppointmentController>()
            .loadAppointments(auth.currentUser!.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BrandedAppBar(
        title: "Lịch hẹn",
        showBackButton: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: "Sắp tới"),
            Tab(text: "Hoàn thành"),
            Tab(text: "Đã hủy"),
          ],
        ),
      ),
      body: Consumer<AppointmentController>(
        builder: (_, controller, __) {
          if (controller.isLoading) {
            return const LoadingWidget(itemCount: 3);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentList(controller.upcomingAppointments,
                  "Chưa có lịch hẹn sắp tới", controller),
              _buildAppointmentList(controller.completedAppointments,
                  "Chưa có lịch hẹn đã hoàn thành", null),
              _buildAppointmentList(controller.cancelledAppointments,
                  "Chưa có lịch hẹn đã hủy", null),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentList(
    List appointments,
    String emptyMessage,
    AppointmentController? controller,
  ) {
    if (appointments.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.calendar_today_outlined,
        title: emptyMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return AppointmentCard(
          doctorName: appointment.doctorName,
          specialty: appointment.specialty,
          dateTime: appointment.dateTime,
          status: appointment.status,
          onCancel: controller != null
              ? () => _showCancelDialog(controller, appointment.id)
              : null,
        );
      },
    );
  }

  void _showCancelDialog(AppointmentController controller, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Hủy lịch hẹn?"),
        content: const Text("Bạn có chắc chắn muốn hủy lịch hẹn này?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Không"),
          ),
          TextButton(
            onPressed: () {
              controller.cancelAppointment(id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text("Hủy lịch"),
          ),
        ],
      ),
    );
  }
}
