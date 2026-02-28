import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';

class ProviderTypeOption {
  final String value;
  final String title;
  final String subtitle;
  final IconData icon;

  const ProviderTypeOption({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class ProviderTypeSelector extends StatelessWidget {
  final String? selectedProviderType;
  final bool showError;
  final ValueChanged<String> onSelected;

  const ProviderTypeSelector({
    super.key,
    required this.selectedProviderType,
    required this.showError,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final options = <ProviderTypeOption>[
      const ProviderTypeOption(
        value: 'vet',
        title: 'Veterinary Clinic',
        subtitle: 'Vet & medical services',
        icon: Icons.medical_services_rounded,
      ),
      const ProviderTypeOption(
        value: 'shop',
        title: 'Pet Shop',
        subtitle: 'Products & retail services',
        icon: Icons.storefront_rounded,
      ),
      const ProviderTypeOption(
        value: 'babysitter',
        title: 'Groomer / Babysitter',
        subtitle: 'Grooming & pet care',
        icon: Icons.pets_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Provider type',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options.map((option) {
            final isSelected = selectedProviderType == option.value;
            return InkWell(
              onTap: () => onSelected(option.value),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentColor.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.accentColor
                        : Colors.black.withValues(alpha: 0.08),
                    width: isSelected ? 1.6 : 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentColor.withValues(alpha: 0.16)
                            : Colors.black.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        option.icon,
                        size: 20,
                        color: isSelected
                            ? AppColors.accentColor
                            : AppColors.iconPrimaryColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? AppColors.accentColor
                                : Colors.black.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          option.subtitle,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (showError) ...[
          const SizedBox(height: 10),
          Text(
            'Please select a provider type to continue',
            style: TextStyle(
              color: Colors.red.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
