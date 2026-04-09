import 'package:flutter/material.dart';
import '../screens/admin_dashboard_screen.dart';
import '../screens/doctor_home_screen.dart';
import '../screens/patient_home_screen.dart';

void navigateByRole(BuildContext context, String role) {
  Widget destination;
  switch (role) {
    case 'admin':
    case 'super_admin':
    case 'hospital_manager':
      destination = const AdminDashboardScreen();
      break;
    case 'doctor':
      destination = const DoctorHomeScreen();
      break;
    case 'patient':
    default:
      destination = const PatientHomeScreen();
      break;
  }

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => destination),
    (route) => false,
  );
}
