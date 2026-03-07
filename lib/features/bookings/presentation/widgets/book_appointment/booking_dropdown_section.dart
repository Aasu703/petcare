import 'package:flutter/material.dart';
import 'package:petcare/app/l10n/app_localizations.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/provider/domain/entities/provider_entity.dart';
import 'package:petcare/features/services/domain/entities/service_entity.dart';

/// Booking form section for selecting pet, service, and provider
class BookingDropdownSection extends StatelessWidget {
  final bool isPetLoading;
  final List<PetEntity> pets;
  final String? selectedPetId;
  final ValueChanged<String?> onPetChanged;
  final bool isServiceLoading;
  final List<ServiceEntity> services;
  final ServiceEntity? selectedService;
  final ValueChanged<ServiceEntity?> onServiceChanged;
  final bool isProviderLoading;
  final List<ProviderEntity> providers;
  final String? selectedProviderId;
  final ValueChanged<String?> onProviderChanged;

  const BookingDropdownSection({
    super.key,
    required this.isPetLoading,
    required this.pets,
    required this.selectedPetId,
    required this.onPetChanged,
    required this.isServiceLoading,
    required this.services,
    required this.selectedService,
    required this.onServiceChanged,
    required this.isProviderLoading,
    required this.providers,
    required this.selectedProviderId,
    required this.onProviderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tr('selectPet'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        isPetLoading
            ? const LinearProgressIndicator(minHeight: 2)
            : DropdownButtonFormField<String>(
                initialValue: selectedPetId,
                items: pets
                    .map(
                      (pet) => DropdownMenuItem(
                        value: pet.petId,
                        child: Text('${pet.name} - ${pet.species}'),
                      ),
                    )
                    .toList(),
                onChanged: onPetChanged,
                decoration: InputDecoration(
                  hintText: pets.isEmpty ? 'No pets found' : 'Choose a pet',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
        const SizedBox(height: 20),
        Text(
          l10n.tr('selectService'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        isServiceLoading
            ? const LinearProgressIndicator(minHeight: 2)
            : DropdownButtonFormField<ServiceEntity>(
                initialValue: selectedService,
                items: services
                    .map(
                      (service) => DropdownMenuItem(
                        value: service,
                        child: Text(
                          '${service.title} - \$${service.price.toStringAsFixed(2)}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onServiceChanged,
                decoration: InputDecoration(
                  hintText: services.isEmpty
                      ? 'No services available'
                      : 'Choose a service',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
        const SizedBox(height: 20),
        Text(
          l10n.tr('selectProvider'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        isProviderLoading
            ? const LinearProgressIndicator(minHeight: 2)
            : DropdownButtonFormField<String>(
                initialValue: selectedProviderId,
                items: providers
                    .map(
                      (provider) => DropdownMenuItem(
                        value: provider.providerId,
                        child: Text(provider.businessName),
                      ),
                    )
                    .toList(),
                onChanged: onProviderChanged,
                decoration: InputDecoration(
                  hintText: providers.isEmpty
                      ? 'No providers available'
                      : 'Choose a provider',
                  filled: true,
                  fillColor: context.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
      ],
    );
  }
}
