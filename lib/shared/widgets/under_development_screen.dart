import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/shared/widgets/empty_state_widget.dart';
import 'package:smart_clinic_booking/core/localization/language_controller.dart';
import 'package:smart_clinic_booking/core/localization/app_language.dart';

class UnderDevelopmentScreen extends ConsumerWidget {
  final String title;

  const UnderDevelopmentScreen({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageControllerProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: BrandedAppBar(
        title: title,
        showBackButton: true,
        centerTitle: true,
      ),
      body: EmptyStateWidget(
        icon: Icons.construction_rounded,
        title: lang.localize(
          'Tính năng đang phát triển',
          'Feature Under Development'
        ),
        subtitle: lang.localize(
          'Tính năng "$title" đang được chúng tôi hoàn thiện và sẽ sớm ra mắt.',
          'The "$title" feature is being developed and will be available soon.'
        ),
      ),
    );
  }
}
