import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_clinic_booking/shared/widgets/appointment_card.dart';

void main() {
  testWidgets('AppointmentCard shows mapped appointment status text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppointmentCard(
            doctorName: 'Dr. Nguyen',
            specialty: 'Cardiology',
            dateTime: DateTime(2026, 4, 9, 10, 0),
            status: 'in_queue',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Dr. Nguyen'), findsOneWidget);
    expect(find.text('Dang cho kham'), findsOneWidget);
  });
}
