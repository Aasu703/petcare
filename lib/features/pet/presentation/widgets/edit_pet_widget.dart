import 'package:flutter/material.dart';

class EditPetWidget extends StatelessWidget {
  final Map<String, dynamic> pet;
  const EditPetWidget({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Edit ${pet['name'] ?? 'Pet'}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text('Edit form placeholder'),
        ],
      ),
    );
  }
}
