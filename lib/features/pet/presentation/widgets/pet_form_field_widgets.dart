import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/shared/widgets/app_form_field.dart';

class PetFormLabel extends StatelessWidget {
  final String text;

  const PetFormLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return AppFormLabel(text: text);
  }
}

class PetFormTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const PetFormTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppFormTextField(
      controller: controller,
      hintText: hintText,
      prefixIcon: prefixIcon,
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}

class PetSpeciesSelector extends StatelessWidget {
  final String selectedSpecies;
  final ValueChanged<String> onChanged;

  const PetSpeciesSelector({
    super.key,
    required this.selectedSpecies,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _speciesOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedSpecies == option.value;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(option.value),
            child: Container(
              margin: EdgeInsets.only(
                right: index == _speciesOptions.length - 1 ? 0 : 8,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor.withValues(alpha: 0.1)
                    : AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.borderColor.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(option.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primaryColor
                          : context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PetSpeciesOption {
  final String value;
  final String label;
  final String emoji;

  const _PetSpeciesOption({
    required this.value,
    required this.label,
    required this.emoji,
  });
}

const List<_PetSpeciesOption> _speciesOptions = [
  _PetSpeciesOption(value: 'dog', label: 'Dog', emoji: '\u{1F415}'),
  _PetSpeciesOption(value: 'cat', label: 'Cat', emoji: '\u{1F408}'),
  _PetSpeciesOption(value: 'bird', label: 'Bird', emoji: '\u{1F99C}'),
  _PetSpeciesOption(value: 'other', label: 'Other', emoji: '\u{1F43E}'),
];
