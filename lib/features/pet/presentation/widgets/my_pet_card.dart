import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';

class MyPetCard extends StatelessWidget {
  final PetEntity pet;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const MyPetCard({
    super.key,
    required this.pet,
    required this.onTap,
    required this.onDelete,
  });

  String _getSpeciesEmoji(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return 'D';
      case 'cat':
        return 'C';
      case 'bird':
        return 'B';
      default:
        return 'P';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = pet.imageUrl;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: context.isDark ? 0.25 : 0.06,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor.withValues(alpha: 0.1),
                    AppColors.accentColor.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: ApiEndpoints.resolveMediaUrl(imageUrl),
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
                            style: const TextStyle(fontSize: 26),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          _getSpeciesEmoji(pet.species),
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pet.species.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (pet.breed != null && pet.breed!.isNotEmpty) ...[
                        const SizedBox(width: 8),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (pet.age != null) ...[
                        Icon(
                          Icons.cake_outlined,
                          size: 14,
                          color: context.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${pet.age} ${pet.age == 1 ? 'year' : 'years'}',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                      if (pet.age != null && pet.weight != null) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: context.borderColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (pet.weight != null) ...[
                        Icon(
                          Icons.monitor_weight_outlined,
                          size: 14,
                          color: context.textSecondary,
                        ),
                        const SizedBox(width: 4),
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
            IconButton(
              icon: const Icon(
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
