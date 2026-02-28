import 'package:flutter/material.dart';

class AddPetWidget extends StatelessWidget {
  const AddPetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Pet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          const Text('Form placeholder — name, species, age, photo'),
        ],
      ),
    );
  }
}
