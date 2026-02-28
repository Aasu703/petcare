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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Pet',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: const Text(
          'Are you sure you want to delete this pet? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
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
            child: const Text('Delete'),
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
          success ? 'Pet deleted successfully' : 'Failed to delete pet',
        ),
        backgroundColor: success
            ? AppColors.successColor
            : AppColors.errorColor,
      ),
    );
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
    final petState = ref.watch(petNotifierProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Pets',
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
        label: const Text(
          'Add Pet',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}
