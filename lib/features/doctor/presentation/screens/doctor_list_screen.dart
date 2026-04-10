import 'package:flutter/material.dart';

import 'doctor_search_screen.dart';

/// Prefer [DoctorSearchScreen]; kept for backward compatibility.
class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DoctorSearchScreen();
  }
}
