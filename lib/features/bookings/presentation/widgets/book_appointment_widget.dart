import 'package:flutter/material.dart';

class BookAppointmentWidget extends StatelessWidget {
  final String? providerName;
  const BookAppointmentWidget({super.key, this.providerName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Book Appointment',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Text('Provider: ${providerName ?? 'Any'}'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_month),
            label: const Text('Pick date & time'),
          ),
        ],
      ),
    );
  }
}
