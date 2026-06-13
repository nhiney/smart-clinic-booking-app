import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void navigateByRole(BuildContext context, String role) {
  switch (role) {
    case 'admin':
    case 'super_admin':
    case 'hospital_manager':
      context.go('/admin/dashboard');
      break;
    case 'doctor':
      context.go('/doctor/dashboard');
      break;
    case 'patient':
    default:
      context.go('/home');
      break;
  }
}
