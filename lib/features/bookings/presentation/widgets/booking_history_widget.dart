import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';

class BookingHistoryWidget extends StatelessWidget {
  final List<BookingEntity> bookings;
  const BookingHistoryWidget({super.key, this.bookings = const []});

  @override
  Widget build(BuildContext context) {
    return bookings.isEmpty
        ? const Center(child: Text('No booking history'))
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              final dt = DateTime.tryParse(b.startTime);
              final label = dt != null
                  ? DateFormat('MMM d, yyyy – hh:mm a').format(dt)
                  : b.startTime;
              final title = b.serviceId ?? b.notes ?? 'Appointment';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(title),
                  subtitle: Text(label),
                ),
              );
            },
          );
  }
}
