import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/branded_app_bar.dart';

class CreateAppointmentScreen extends ConsumerStatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  ConsumerState<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends ConsumerState<CreateAppointmentScreen> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
  String? selectedTimeSlot;
  final TextEditingController _symptomsController = TextEditingController();

  final List<String> _timeSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '13:30', '14:00', '14:30', '15:00', '15:30', '16:00',
  ];

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(context.spacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDoctorCard(context),
                  SizedBox(height: context.spacing.l),
                  _buildSectionTitle(context, 'Chọn ngày khám'),
                  SizedBox(height: context.spacing.m),
                  _buildDatePicker(context),
                  SizedBox(height: context.spacing.l),
                  _buildSectionTitle(context, 'Chọn khung giờ'),
                  SizedBox(height: context.spacing.m),
                  _buildTimeGrid(context),
                  SizedBox(height: context.spacing.l),
                  _buildSectionTitle(context, 'Triệu chứng & Ghi chú'),
                  SizedBox(height: context.spacing.m),
                  _buildSymptomsInput(context),
                  SizedBox(height: context.spacing.xxl),
                  _buildSubmitButton(context),
                  SizedBox(height: context.spacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: context.colors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Đặt lịch khám',
          style: context.textStyles.heading3.copyWith(color: Colors.white),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.colors.primary, context.colors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 150,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: context.textStyles.subtitle.copyWith(
        fontWeight: FontWeight.bold,
        color: context.colors.primaryDark,
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.spacing.m),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: context.radius.lRadius,
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: context.radius.mRadius,
              image: const DecorationImage(
                image: NetworkImage('https://i.pravatar.cc/150?u=doctor2'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: context.spacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BS. Trần Thị Phương Thảo',
                  style: context.textStyles.bodyBold,
                ),
                Text(
                  'Chuyên khoa Nhi • BV Nhi Đồng 1',
                  style: context.textStyles.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                SizedBox(height: context.spacing.xs),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    SizedBox(width: context.spacing.xs),
                    Text(
                      '4.9 (120 đánh giá)',
                      style: context.textStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.info_outline_rounded, color: context.colors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime.now().add(Duration(days: index + 1));
          final isSelected = DateFormat('yyyy-MM-dd').format(date) == 
                             DateFormat('yyyy-MM-dd').format(selectedDate);
          
          return GestureDetector(
            onTap: () => setState(() => selectedDate = date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 65,
              margin: EdgeInsets.only(right: context.spacing.m),
              decoration: BoxDecoration(
                color: isSelected ? context.colors.primary : context.colors.surface,
                borderRadius: context.radius.mRadius,
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: context.colors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ] : [],
                border: Border.all(
                  color: isSelected ? context.colors.primary : context.colors.divider,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date).toUpperCase(),
                    style: context.textStyles.caption.copyWith(
                      color: isSelected ? Colors.white70 : context.colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: context.spacing.xs),
                  Text(
                    DateFormat('dd').format(date),
                    style: context.textStyles.heading3.copyWith(
                      color: isSelected ? Colors.white : context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: _timeSlots.length,
      itemBuilder: (context, index) {
        final time = _timeSlots[index];
        final isSelected = selectedTimeSlot == time;

        return GestureDetector(
          onTap: () => setState(() => selectedTimeSlot = time),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? context.colors.primary : context.colors.surface,
              borderRadius: context.radius.sRadius,
              border: Border.all(
                color: isSelected ? context.colors.primary : context.colors.divider,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              time,
              style: context.textStyles.bodySmall.copyWith(
                color: isSelected ? Colors.white : context.colors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSymptomsInput(BuildContext context) {
    return TextField(
      controller: _symptomsController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Mô tả ngắn gọn các triệu chứng của bạn để bác sĩ nắm bắt thông tin...',
        filled: true,
        fillColor: context.colors.surface,
        border: OutlineInputBorder(
          borderRadius: context.radius.mRadius,
          borderSide: BorderSide(color: context.colors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: context.radius.mRadius,
          borderSide: BorderSide(color: context.colors.divider),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return AppButton(
      text: 'Xác nhận đặt lịch',
      onPressed: () {
        if (selectedTimeSlot == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Vui lòng chọn khung giờ khám')),
          );
          return;
        }
        _showSuccessDialog(context);
      },
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: context.radius.lRadius),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text('Đặt lịch thành công!', style: context.textStyles.heading2),
            const SizedBox(height: 10),
            Text(
              'Lịch hẹn của bạn đã được ghi nhận. Vui lòng có mặt đúng giờ để được thăm khám tốt nhất.',
              textAlign: TextAlign.center,
              style: context.textStyles.body.copyWith(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Về trang chủ',
              onPressed: () {
                Navigator.pop(context); // Close dialog
                context.go('/patient-home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
