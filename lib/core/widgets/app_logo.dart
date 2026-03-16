import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.local_hospital,
            size: 40,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Smart Clinic",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          "Booking App",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        )
      ],
    );
  }
}
