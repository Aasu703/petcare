import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';
import 'package:petcare/features/pet/presentation/pages/add_pet.dart';
import 'package:petcare/features/pet/presentation/pages/edit_pet.dart';
import 'package:petcare/features/pet/presentation/provider/pet_providers.dart';
import 'package:petcare/app/theme/theme_extensions.dart';

class MyPet extends ConsumerStatefulWidget {
  MyPet({super.key});

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
        content: Text(
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
            child: Text('Delete'),
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

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Pets', style: Theme.of(context).textTheme.titleLarge),
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: AppColors.primaryColor,
        child: petState.isLoading && petState.pets.isEmpty
            ? Center(child: CircularProgressIndicator())
            : petState.pets.isEmpty
            ? _buildEmptyState()
            : ListView.separated(
                padding: EdgeInsets.all(20),
                itemCount: petState.pets.length,
                separatorBuilder: (_, __) => SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final pet = petState.pets[index];
                  return _PetCard(
                    pet: pet,
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPetScreen(pet: pet),
                        ),
                      );
                      if (updated == true) {
                        await _refresh();
                      }
                    },
                    onDelete: () => _deletePet(pet.petId ?? ''),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPet()),
          );
          if (added == true) {
            await _refresh();
          }
        },
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.buttonTextColor,
        elevation: 4,
        icon: Icon(Icons.add),
        label: Text('Add Pet', style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      padding: EdgeInsets.all(40),
      children: [
        SizedBox(height: 80),
        Icon(
          Icons.pets,
          size: 120,
          color: AppColors.iconSecondaryColor.withOpacity(0.3),
        ),
        SizedBox(height: 24),
        Text(
          'No Pets Yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.textPrimary,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Start adding your beloved pets to keep track of their information and care.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: context.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _PetCard extends StatelessWidget {
  final PetEntity pet;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  _PetCard({required this.pet, required this.onTap, required this.onDelete});

  String _getSpeciesEmoji(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return '🐕';
      case 'cat':
        return '🐈';
      case 'bird':
        return '🦜';
      default:
        return '🐾';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = pet.imageUrl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.textPrimary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: context.textPrimary.withOpacity(0.04),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Pet Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withOpacity(0.1),
                    AppColors.accentColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: '${ApiEndpoints.mediaServerUrl}$imageUrl',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            _getSpeciesEmoji(pet.species),
                            style: TextStyle(fontSize: 32),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          _getSpeciesEmoji(pet.species),
                          style: TextStyle(fontSize: 32),
                        ),
                      ),
              ),
            ),
            SizedBox(width: 16),

            // Pet Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: context.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pet.species.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (pet.breed != null && pet.breed!.isNotEmpty) ...[
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pet.breed!,
                            style: TextStyle(
                              fontSize: 14,
                              color: context.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      if (pet.age != null) ...[
                        Icon(
                          Icons.cake_outlined,
                          size: 14,
                          color: AppColors.iconSecondaryColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${pet.age} ${pet.age == 1 ? 'year' : 'years'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                      if (pet.age != null && pet.weight != null) ...[
                        SizedBox(width: 12),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.borderColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 12),
                      ],
                      if (pet.weight != null) ...[
                        Icon(
                          Icons.monitor_weight_outlined,
                          size: 14,
                          color: AppColors.iconSecondaryColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${pet.weight} kg',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Delete Button
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: AppColors.errorColor,
                size: 22,
              ),
              onPressed: onDelete,
              tooltip: 'Delete pet',
            ),
          ],
        ),
      ),
    );
  }
}
