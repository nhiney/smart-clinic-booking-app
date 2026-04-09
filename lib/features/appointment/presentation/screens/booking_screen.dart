import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/typography/app_text_styles.dart';
import '../../../doctor/domain/entities/doctor_entity.dart';
import '../../domain/entities/appointment_entity.dart';
import '../controllers/appointment_controller.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../../core/widgets/branded_app_bar.dart';

class BookingScreen extends StatefulWidget {
  final DoctorEntity doctor;

  const BookingScreen({super.key, required this.doctor});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String? selectedTime;
  final notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> handleBooking() async {
    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn giờ khám')),
      );
      return;
    }

    final auth = context.read<AuthController>();
    final appointmentController = context.read<AppointmentController>();

    final timeParts = selectedTime!.split(':');
    final dateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );

    final appointment = AppointmentEntity(
      id: '',
      patientId: auth.currentUser?.id ?? '',
      patientName: auth.currentUser?.name ?? '',
      doctorId: widget.doctor.id,
      doctorName: widget.doctor.name,
      specialty: widget.doctor.specialty,
      dateTime: dateTime,
      notes: notesController.text.trim(),
    );

    final success = await appointmentController.createAppointment(appointment);

    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text("Đặt lịch thành công!", style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(
                "${widget.doctor.name}\n${DateFormat('dd/MM/yyyy').format(selectedDate)} - $selectedTime",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Đóng"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(appointmentController.errorMessage ?? 'Đặt lịch thất bại'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Đặt lịch khám")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 8),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primarySurface,
                    child: const Icon(Icons.person,
                        color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.doctor.name, style: AppTextStyles.subtitle),
                      Text(widget.doctor.specialty,
                          style: AppTextStyles.bodySmall),
                      Text(widget.doctor.hospital,
                          style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select date
            Text("Chọn ngày khám", style: AppTextStyles.heading3),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: pickDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, dd/MM/yyyy', 'vi').format(selectedDate),
                      style: AppTextStyles.subtitle,
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down,
                        color: AppColors.textHint),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Select time
            Text("Chọn giờ khám", style: AppTextStyles.heading3),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: widget.doctor.availableTimeSlots.map((time) {
                final isSelected = selectedTime == time;
                return GestureDetector(
                  onTap: () => setState(() => selectedTime = time),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : AppColors.divider,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: AppColors.primary.withOpacity(0.3),
                                  blurRadius: 8)
                            ]
                          : null,
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Notes
            Text("Ghi chú (tùy chọn)", style: AppTextStyles.heading3),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Mô tả triệu chứng hoặc ghi chú...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Confirm button
            Consumer<AppointmentController>(
              builder: (_, controller, __) {
                return SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: controller.isLoading ? null : handleBooking,
                    icon: controller.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle),
                    label: Text(controller.isLoading
                        ? "Đang xử lý..."
                        : "Xác nhận đặt lịch"),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
