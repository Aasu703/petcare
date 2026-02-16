import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petcare/features/bookings/domain/entities/booking_entity.dart';

class ProviderCalendarWidget extends StatelessWidget {
  final List<BookingEntity> bookings;
  final DateTime? selectedDay;

  const ProviderCalendarWidget({
    super.key,
    this.bookings = const [],
    this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel = selectedDay != null
        ? DateFormat.yMMMd().format(selectedDay!)
        : 'Select a date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            'Provider Calendar — $dayLabel',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: bookings.isEmpty
              ? Center(child: Text('No appointments yet'))
              : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, i) {
                    final b = bookings[i];
                    final time = DateTime.tryParse(b.startTime);
                    final title = b.serviceId ?? b.notes ?? 'Appointment';
                    return ListTile(
                      leading: const Icon(Icons.event),
                      title: Text(title),
                      subtitle: Text(
                        time != null
                            ? DateFormat('hh:mm a').format(time)
                            : b.startTime,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
