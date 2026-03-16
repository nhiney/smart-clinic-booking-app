import 'package:flutter/material.dart';

class DoctorListScreen extends StatelessWidget {
  const DoctorListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctors = [
      "Dr. John - Cardiology",
      "Dr. Anna - Dermatology",
      "Dr. David - Neurology"
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctors"),
      ),
      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(doctors[index]),
            trailing: const Icon(Icons.arrow_forward_ios),
          );
        },
      ),
    );
  }
}
