import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/presentation/pages/add_pet.dart';
import 'package:petcare/features/pet/presentation/pages/edit_pet.dart';
import 'package:petcare/features/pet/presentation/pages/pet_care_screen.dart';
import 'package:petcare/features/pet/presentation/provider/pet_providers.dart';
import 'package:petcare/features/pet/presentation/widgets/my_pet_card.dart';
import 'package:petcare/features/pet/presentation/widgets/my_pet_empty_state.dart';
import 'package:petcare/app/l10n/app_localizations.dart';

class MyPet extends ConsumerStatefulWidget {
  const MyPet({super.key});

  @override
  ConsumerState<MyPet> createState() => _MyPetState();
}

class _MyPetState extends ConsumerState<MyPet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(petNotifierProvider.notifier).getAllPets());
  }

  Future<void> _refresh() async {
    await ref.read(petNotifierProvider.notifier).getAllPets();
  }

  Future<void> _deletePet(String petId) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.tr('deletePet'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(l10n.tr('deletePetConfirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.tr('cancel'),
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              foregroundColor: context.textPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.tr('delete')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(petNotifierProvider.notifier)
        .deletePet(petId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? l10n.tr('petDeletedSuccess') : l10n.tr('failedDeletePet'),
        ),
        backgroundColor: success
            ? AppColors.successColor
            : AppColors.errorColor,
      ),
    );
  }

  Future<void> _assignVet(PetEntity pet) async {
    final notifier = ref.read(petNotifierProvider.notifier);
    await notifier.loadVerifiedVets();
    final vets = ref.read(petNotifierProvider).verifiedVets;

    if (!mounted) return;

    final selectedVet = await showModalBottomSheet<Map<String, String>>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        if (vets.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.info_outline, size: 32),
                SizedBox(height: 12),
                Text('No verified vets found right now'),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.medical_services_outlined),
                  SizedBox(width: 8),
                  Text(
                    'Assign a vet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...vets.map(
                (vet) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.pets)),
                  title: Text(vet['name'] ?? 'Vet'),
                  onTap: () => Navigator.pop(context, vet),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedVet == null || (pet.petId ?? '').isEmpty) return;

    final ok = await notifier.assignVet(
      petId: pet.petId!,
      vetId: selectedVet['id']!,
    );

    if (!mounted) return;
    final message = ok ? 'Vet assigned successfully' : 'Could not assign vet';
    final color = ok ? AppColors.successColor : AppColors.errorColor;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _onPetTap(PetEntity pet) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPetScreen(pet: pet)),
    );
    if (updated == true) {
      await _refresh();
    }
  }

  Future<void> _onAddPetTap() async {
    final added = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPet()),
    );
    if (added == true) {
      await _refresh();
    }
  }

  Future<void> _onCareTap(PetEntity pet) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PetCareScreen(pet: pet)),
    );
    if (updated == true) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final petState = ref.watch(petNotifierProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.tr('myPets'),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: context.surfaceColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryColor,
        backgroundColor: context.surfaceColor,
        child: petState.isLoading && petState.pets.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              )
            : petState.error != null && petState.pets.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 42,
                        color: AppColors.errorColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load pets',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        petState.error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : petState.pets.isEmpty
            ? const MyPetEmptyState()
            : CustomScrollView(
                slivers: [
                  // Header Section with Pet Count
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryColor.withValues(
                                    alpha: 0.08,
                                  ),
                                  AppColors.accentColor.withValues(alpha: 0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.primaryColor.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Your Pet Family',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: context.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${petState.pets.length} ${petState.pets.length == 1 ? 'pet' : 'pets'}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: context.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    border: Border.all(
                                      color: AppColors.primaryColor.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.pets,
                                      color: AppColors.primaryColor,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Pet List
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                    sliver: SliverList.separated(
                      itemCount: petState.pets.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final pet = petState.pets[index];
                        return MyPetCard(
                          pet: pet,
                          onTap: () => _onPetTap(pet),
                          onCare: () => _onCareTap(pet),
                          onAssignVet: () => _assignVet(pet),
                          onDelete: () => _deletePet(pet.petId ?? ''),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onAddPetTap,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.buttonTextColor,
        elevation: 6,
        icon: const Icon(Icons.add),
        label: Text(
          l10n.tr('addPet'),
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}
