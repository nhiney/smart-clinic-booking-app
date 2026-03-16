import 'package:flutter/material.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
      ),
      body: Column(
        children: [
          ElevatedButton(
            child: const Text("Select Date"),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2030),
              );

              if (date != null) {
                setState(() {
                  selectedDate = date;
                });
              }
            },
          ),
          Text("Selected: $selectedDate"),
        ],
      ),
    );
  }
}
