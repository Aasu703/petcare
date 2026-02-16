import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';

class BookingCalendarWidget extends StatelessWidget {
  final List<BookingEntity> bookings;
  const BookingCalendarWidget({super.key, this.bookings = const []});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            'Bookings Calendar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: bookings.isEmpty
              ? const Center(child: Text('No bookings'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (c, i) {
                    final b = bookings[i];
                    final dt = DateTime.tryParse(b.startTime);
                    final date = dt != null
                        ? DateFormat('EEE, MMM d').format(dt)
                        : b.startTime;
                    final title = b.serviceId ?? b.notes ?? 'Appointment';
                    return ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(title),
                      subtitle: Text(date),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(),
                  itemCount: bookings.length,
                ),
        ),
      ],
    );
  }
}
