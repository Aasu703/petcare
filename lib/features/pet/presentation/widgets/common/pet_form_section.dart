import 'package:flutter/material.dart';
import 'package:petcare/features/pet/presentation/widgets/pet_form_field_widgets.dart';

/// Complete pet form section with all input fields
/// Used in both add and edit pet screens
class PetFormSection extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController breedController;
  final TextEditingController ageController;
  final TextEditingController weightController;
  final String selectedSpecies;
  final ValueChanged<String> onSpeciesChanged;

  const PetFormSection({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.breedController,
    required this.ageController,
    required this.weightController,
    required this.selectedSpecies,
    required this.onSpeciesChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PetFormLabel(text: 'Pet Name'),
          const SizedBox(height: 8),
          PetFormTextField(
            controller: nameController,
            hintText: 'Enter pet name',
            prefixIcon: Icons.pets,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Pet name is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          const PetFormLabel(text: 'Species'),
          const SizedBox(height: 8),
          PetSpeciesSelector(
            selectedSpecies: selectedSpecies,
            onChanged: onSpeciesChanged,
          ),
          const SizedBox(height: 20),
          const PetFormLabel(text: 'Breed (Optional)'),
          const SizedBox(height: 8),
          PetFormTextField(
            controller: breedController,
            hintText: 'Enter breed',
            prefixIcon: Icons.category_outlined,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PetFormLabel(text: 'Age (years)'),
                    const SizedBox(height: 8),
                    PetFormTextField(
                      controller: ageController,
                      hintText: '0',
                      prefixIcon: Icons.cake_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PetFormLabel(text: 'Weight (kg)'),
                    const SizedBox(height: 8),
                    PetFormTextField(
                      controller: weightController,
                      hintText: '0.0',
                      prefixIcon: Icons.monitor_weight_outlined,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
